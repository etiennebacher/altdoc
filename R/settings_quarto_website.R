.finalize_quarto_website <- function(
    settings,
    path,
    verbose = FALSE,
    freeze = FALSE,
    ...
) {
    # WARNING: Note the different _quarto folder. This is an imortant design
    # choice because we want to use the built-in freeze functionality of quarto
    # and need to move _quarto/_site to docs/ after rendering.

    # drop empty lines
    settings <- settings[!grepl("^\\w*$", settings)]
    settings <- yaml::as.yaml(
        settings,
        indent.mapping.sequence = TRUE,
        handler = list(logical = yaml::verbatim_logical)
    )
    settings <- strsplit(settings, "\\n")[[1]]
    writeLines(settings, fs::path_join(c(path, "_quarto", "_quarto.yml")))

    # NEWS.qmd breaks rendering, so we delete it if NEWS.md is available.
    # This happens when converting from NEWS.Rd
    a <- fs::path_join(c(path, "_quarto", "NEWS.md"))
    b <- fs::path_join(c(path, "_quarto", "NEWS.qmd"))
    if (fs::file_exists(a) && fs::file_exists(b)) {
        fs::file_delete(b)
    }

    tar <- .doc_path(path)
    fs::dir_create(tar)

    # CNAME is used by Github and other providers to redirect to a custom domain
    files <- Filter(function(f) basename(f) != "CNAME", fs::dir_ls(tar))
    # Clear out `tar`
    fs::file_delete(files)

    # Stage files pulled in by `{{< include >}}` directives that live outside
    # the copied source trees (e.g. a shared `macros/macros.qmd` submodule at
    # the package root). Quarto resolves include paths relative to the
    # including file, so these must exist under `_quarto/` before rendering.
    .stage_external_includes(
        src_dir = path,
        quarto_dir = fs::path_join(c(path, "_quarto"))
    )

    # render to `output-dir: ../docs/`
    quarto::quarto_render(
        input = fs::path_join(c(path, "_quarto")),
        quiet = !verbose,
        as_job = FALSE,
        use_freezer = freeze
    )

    # copy the content of altdoc/ to docs/. This is important because the
    # process above rendered the site in a completely different directory, so
    # did not have the static files, and we want the static files in altdoc/ to
    # be served on the website. This a core feature of altdoc: users can store
    # files in altdoc/ and those will be copied to the root of the website

    # this can be done automatically with `project:` > `resources: ../altdoc/`
    fs::dir_copy(fs::path_join(c(path, "altdoc")), tar, overwrite = TRUE)
}

.sidebar_vignettes_quarto_website <- function(sidebar, path) {
    fn_vignettes <- list.files(
        fs::path_join(c(path, "_quarto/vignettes")),
        pattern = "\\.qmd$|\\.Rmd|\\.pdf$",
        full.names = TRUE,
        recursive = TRUE
    )
    fn_man <- list.files(
        fs::path_join(c(path, "_quarto/man")),
        pattern = "\\.qmd$",
        full.names = TRUE
    )

    # issue #266: add word boundary check
    fn_man <- gsub(".*\\b_quarto.", "", fn_man)
    fn_vignettes <- gsub(".*_quarto.", "", fn_vignettes)

    yml <- paste(sidebar, collapse = "\n")
    yml <- yaml::yaml.load(yml, handlers = list(seq = function(x) as.list(x)))

    # reverse order because we delete elements
    for (i in rev(seq_along(yml$website$sidebar$contents))) {
        if (!"section" %in% names(yml$website$sidebar$contents[[i]])) {
            next
        }
        if (
            isTRUE(
                yml$website$sidebar$contents[[i]]$section[[1]] ==
                    "$ALTDOC_VIGNETTE_BLOCK"
            )
        ) {
            if (length(fn_vignettes) > 0) {
                fn_vignettes <- lapply(fn_vignettes, function(x) {
                    # Quarto cannot retrieve titles from .pdf, so we use the file name
                    if (tools::file_ext(x) == "pdf") {
                        list(
                            text = sub("\\.pdf$", "", basename(x)),
                            file = x
                        )
                        # Quarto retrieves the title from .qmd files automatically, so we only supply the file path
                    } else {
                        x
                    }
                })
                yml$website$sidebar$contents[[i]] <- list(
                    section = "Articles",
                    contents = fn_vignettes
                )
            } else {
                yml$website$sidebar$contents[[i]] <- NULL
            }
        } else if (
            isTRUE(
                yml$website$sidebar$contents[[i]]$section[[1]] ==
                    "$ALTDOC_MAN_BLOCK"
            )
        ) {
            if (length(fn_man) > 0) {
                man_list <- lapply(
                    fn_man,
                    function(x) {
                        list(
                            text = sub("\\.qmd$", "", basename(x)),
                            file = x
                        )
                    }
                )
                yml$website$sidebar$contents[[i]] <- list(
                    section = "Reference",
                    contents = man_list
                )
            } else {
                yml$website$sidebar$contents[[i]] <- NULL
            }
        }
    }

    return(yml)
}

.sidebar_man_quarto_website <- function(sidebar, path, ...) {
    # the sidebar should not include text entries with no associated link
    # delete backwards to preserve order
    for (i in rev(seq_along(sidebar$website$sidebar$contents))) {
        tmp <- sidebar$website$sidebar$contents[[i]]
        if ("text" %in% names(tmp) && !"file" %in% names(tmp)) {
            sidebar$website$sidebar$contents[[i]] <- NULL
        }
    }
    return(sidebar)
}

# Copy files referenced by Quarto `{{< include >}}` directives that resolve to
# a location outside the `_quarto/` build tree into the matching spot under
# `_quarto/`, so Quarto can find them at render time.
#
# altdoc stages `vignettes/`, `man/`, and the miscellaneous root files into
# `_quarto/`, but an include such as `{{< include ../macros/macros.qmd >}}`
# (common when a package shares its LaTeX macros via a submodule at the package
# root) points outside those trees and is otherwise never copied. Because
# Quarto resolves include paths relative to the including file, the referenced
# file must live at the same relative path under `_quarto/`. This walks the
# staged files, follows their includes recursively, and copies each
# externally-referenced file from the source tree into `_quarto/`.
.stage_external_includes <- function(src_dir, quarto_dir) {
    src_dir <- fs::path_abs(src_dir)
    quarto_dir <- fs::path_abs(quarto_dir)
    include_re <- "\\{\\{<\\s*include\\s+([^>]+?)\\s*>\\}\\}"

    queue <- list.files(
        quarto_dir,
        pattern = "\\.qmd$|\\.Rmd$|\\.md$",
        full.names = TRUE,
        recursive = TRUE
    )
    seen <- character(0)

    while (length(queue) > 0) {
        fn <- queue[[1]]
        queue <- queue[-1]
        if (fn %in% seen || !fs::file_exists(fn)) {
            next
        }
        seen <- c(seen, fn)

        matches <- regmatches(
            .readlines(fn),
            regexpr(include_re, .readlines(fn))
        )
        paths <- sub(include_re, "\\1", matches)
        for (inc in unique(trimws(paths))) {
            inc <- gsub('^["\']|["\']$', "", inc)

            # only includes that escape the copied tree need staging; the rest
            # were already copied with their containing directory
            if (!grepl("\\.\\.", inc)) {
                next
            }

            rel <- fs::path_rel(
                fs::path_norm(fs::path_join(c(fs::path_dir(fn), inc))),
                start = quarto_dir
            )
            tar_file <- fs::path_join(c(quarto_dir, rel))
            src_file <- fs::path_join(c(src_dir, rel))

            if (fs::file_exists(tar_file)) {
                queue <- c(queue, tar_file)
                next
            }
            if (fs::file_exists(src_file)) {
                fs::dir_create(fs::path_dir(tar_file))
                fs::file_copy(src_file, tar_file, overwrite = TRUE)
                queue <- c(queue, tar_file)
            }
        }
    }

    invisible()
}
