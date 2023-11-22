.finalize_quarto_website <- function(settings, path, verbose = FALSE, freeze = FALSE, ...) {
    # WARNING: Note the different _quarto folder. This is an imortant design
    # choice because we want to use the built-in freeze functionality of quarto
    # and need to move _quarto/_site to docs/ after rendering.

    # drop empty lines
    settings <- settings[!grepl("^\\w*$", settings)]

    fn <- fs::path_join(c(path, "_quarto", "_quarto.yml"))
    yaml::write_yaml(settings, fn)

    # yaml::write_yaml converts true to yes, but quarto complains
    settings <- .readlines(fn)
    settings <- gsub(": yes$", ": true", settings)
    writeLines(settings, fn)

    tmp <- fs::path_join(c(path, "_quarto", "docs"))
    for (f in fs::dir_ls(tmp)) {
        fs::file_move(f, fs::path_join(c(path, "_quarto")))
    }
    fs::dir_delete(tmp)

    quarto::quarto_render(input = fs::path_join(c(path, "_quarto")), quiet = !verbose, use_freezer = freeze)

    # move _quarto/_site to docs/
    src <- fs::path_join(c(path, "_quarto", "_site"))
    tar <- .doc_path(path)
    if (fs::dir_exists(tar)) {
        fs::dir_delete(tar)
    }
    fs::file_move(src, .doc_path(path))

}


.sidebar_vignettes_quarto_website <- function(sidebar, path) {
    fn_vignettes <- list.files(
        fs::path_join(c(path, "_quarto/docs/vignettes")),
        pattern = "\\.qmd$|\\.Rmd", full.names = TRUE)
    fn_man <- list.files(
        fs::path_join(c(path, "_quarto/docs/man")),
        pattern = "\\.qmd$", full.names = TRUE)

    fn_man <- gsub(".*_quarto.docs.", "", fn_man)
    fn_vignettes <- gsub(".*_quarto.docs.", "", fn_vignettes)

    yml <- paste(sidebar, collapse = "\n")
    yml <- yaml::yaml.load(yml)

    # reverse order because we delete elements
    for (i in rev(seq_along(yml$website$sidebar$contents))) {
        if (isTRUE(yml$website$sidebar$contents[[i]]$section[[1]] == "$ALTDOC_VIGNETTE_BLOCK")) {
            if (length(fn_vignettes) > 0) {
                yml$website$sidebar$contents[[i]] <- list(section = "Articles", contents = fn_vignettes)
            } else {
                yml$website$sidebar$contents[[i]] <- NULL
            }
        } else if (isTRUE(yml$website$sidebar$contents[[i]]$section[[1]] == "$ALTDOC_MAN_BLOCK")) {
            if (length(fn_vignettes) > 0) {
                yml$website$sidebar$contents[[i]] <- list(section = "Reference", contents = fn_man)
            } else {
                yml$website$sidebar$contents[[i]] <- NULL
            }
        }
    }

    return(yml)
}



.sidebar_man_quarto_website <- function(sidebar, path, ...) {
    return(sidebar)
}