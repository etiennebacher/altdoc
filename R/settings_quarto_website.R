.finalize_quarto_website <- function(settings, path, verbose = FALSE, freeze = FALSE, ...) {
    # WARNING: Note the different _quarto folder. This is an imortant design
    # choice because we want to use the built-in freeze functionality of quarto
    # and need to move _quarto/_site to docs/ after rendering.

    # drop empty lines
    settings <- settings[!grepl("^\\w*$", settings)]
    settings <- yaml::as.yaml(
      settings, indent.mapping.sequence = TRUE, 
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
        pattern = "\\.qmd$|\\.Rmd|\\.pdf$", full.names = TRUE)
    fn_man <- list.files(
        fs::path_join(c(path, "_quarto/man")),
        pattern = "\\.qmd$", full.names = TRUE)

    # issue #266: add word boundary check
    fn_man <- gsub(".*\\b_quarto.", "", fn_man)
    fn_vignettes <- gsub(".*_quarto.", "", fn_vignettes)

    yml <- paste(sidebar, collapse = "\n")
    yml <- yaml::yaml.load(yml)

    # reverse order because we delete elements
    for (i in rev(seq_along(yml$website$sidebar$contents))) {
        if (!"section" %in% names(yml$website$sidebar$contents[[i]])) next
        if (isTRUE(yml$website$sidebar$contents[[i]]$section[[1]] == "$ALTDOC_VIGNETTE_BLOCK")) {
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
                    contents = fn_vignettes)
            } else {
                yml$website$sidebar$contents[[i]] <- NULL
            }
        } else if (isTRUE(yml$website$sidebar$contents[[i]]$section[[1]] == "$ALTDOC_MAN_BLOCK")) {
            if (length(fn_man) > 0) {
                man_list <- lapply(fn_man, function(x) list(
                    text = sub("\\.qmd$", "", basename(x)),
                    file = x
                ))
                yml$website$sidebar$contents[[i]] <- list(section = "Reference", contents = man_list)
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


