.finalize_quarto_website <- function(settings, path, verbose = FALSE, freeze = FALSE, ...) {
    # WARNING: Note the different _quarto folder. This is an imortant design
    # choice because we want to use the built-in freeze functionality of quarto
    # and need to move _quarto/_site to docs/ after rendering.

    # drop empty lines
    settings <- settings[!grepl("^\\w*$", settings)]

    fn <- fs::path_join(c(path, "_quarto", "_quarto.yml"))
    yaml::write_yaml(settings, fn, indent.mapping.sequence = TRUE)

    # yaml::write_yaml converts true to yes, but quarto complains
    settings <- .readlines(fn)
    settings <- gsub(": yes$", ": true", settings)
    settings <- gsub(": no$", ": false", settings)
    writeLines(settings, fn)

    tmp <- fs::path_join(c(path, "_quarto", "docs"))
    fs::dir_copy(tmp, fs::path_join(c(path, "_quarto")), overwrite = TRUE)
    fs::dir_delete(tmp)

    # index.md breaks rendering
    fn <- fs::path_join(c(path, "_quarto", "index.md"))
    if (fs::file_exists(fn)) {
        fs::file_delete(fn)
    }

    # NEWS.qmd breaks rendering, so we delete it if NEWS.md is available.
    # This happens when when converting from NEWS.Rd
    a <- fs::path_join(c(path, "_quarto", "NEWS.md"))
    b <- fs::path_join(c(path, "_quarto", "NEWS.qmd"))
    if (fs::file_exists(a) && fs::file_exists(b)) {
        fs::file_delete(b)
    }

    quarto::quarto_render(
        input = fs::path_join(c(path, "_quarto")),
        quiet = !verbose,
        as_job = FALSE,
        use_freezer = freeze)

    # move _quarto/_site to docs/
    # allow book
    for (x in c("_site", "_book")) {
        tmp <- fs::path_join(c(path, "_quarto", x))
        if (fs::file_exists(tmp)) {
            src <- tmp
        }
    }

    tar <- .doc_path(path)

    # CNAME is used by Github and other providers to redirect to a custom domain
    files <- fs::dir_ls(tar)
    for (f in files) {
        if (basename(f) != "CNAME") {
            if (fs::is_dir(f)) fs::dir_delete(f)
            if (fs::is_file(f)) fs::file_delete(f)
        }
    }

    fs::file_move(fs::dir_ls(src), tar)

}


.sidebar_vignettes_quarto_website <- function(sidebar, path) {
    fn_vignettes <- list.files(
        fs::path_join(c(path, "_quarto/docs/vignettes")),
        pattern = "\\.qmd$|\\.Rmd|\\.pdf$", full.names = TRUE)
    fn_man <- list.files(
        fs::path_join(c(path, "_quarto/docs/man")),
        pattern = "\\.qmd$", full.names = TRUE)

    fn_man <- gsub(".*_quarto.docs.", "", fn_man)
    fn_vignettes <- gsub(".*_quarto.docs.", "", fn_vignettes)

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


