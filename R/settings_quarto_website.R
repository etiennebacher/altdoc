.import_settings_quarto_website <- function(path, verbose = FALSE) {


    # Read settings sidebar
    path_parent <- fs::path_abs(gsub("._quarto$", "", path))
    fn <- fs::path_join(c(path_parent, "altdoc", "quarto_website.yml"))
    sidebar <- .readlines(fn)

    # Single files
    if (fs::file_exists(fs::path_join(c(.doc_path(path), "NEWS.md")))) {
        sidebar <- gsub("\\$ALTDOC_NEWS", "NEWS.md", sidebar)
    } else {
        sidebar <- sidebar[!grepl("\\$ALTDOC_NEWS", sidebar)]
    }

    if (fs::file_exists(fs::path_join(c(.doc_path(path), "LICENSE.md")))) {
        sidebar <- gsub("\\$ALTDOC_LICENSE", "LICENSE.md", sidebar)
    } else {
        sidebar <- sidebar[!grepl("\\$ALTDOC_LICENSE", sidebar)]
    }

    if (fs::file_exists(fs::path_join(c(.doc_path(path), "CODE_OF_CONDUCT.md")))) {
        sidebar <- gsub("\\$ALTDOC_CODE_OF_CONDUCT", "CODE_OF_CONDUCT.md", sidebar)
    } else {
        sidebar <- sidebar[!grepl("\\$ALTDOC_CODE_OF_CONDUCT", sidebar)]
    }

    # TODO move code below to separate internal functions, e.g `generate_vignettes()`, `generate_man()`
    # WARNING: Note the different _quarto folder. This is an imortant design
    # choice because we want to use the built-in freeze functionality of quarto
    # and need to move _quarto/_site to docs/ after rendering.

    ############### Vignettes
    fn_vignettes <- list.files(
        fs::path_join(c(.doc_path(path), "vignettes")),
        pattern = "\\.qmd$|\\.Rmd", full.names = TRUE)
    fn_man <- list.files(
        fs::path_join(c(.doc_path(path), "man")),
        pattern = "\\.qmd$", full.names = TRUE)
    fn_vignettes <- gsub(paste0(.doc_path(path), "/"), "", fn_vignettes, fixed = TRUE)
    fn_man <- gsub(paste0(.doc_path(path), "/"), "", fn_man, fixed = TRUE)

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

    tmp <- tempfile()
    yaml::write_yaml(yml, file = tmp)
    sidebar <- .readlines(tmp)

    # drop missing sidebar entries
    sidebar <- gsub("\\* \\[.*\\]\\(\\)$", "", sidebar)

    # drop empty lines
    sidebar <- sidebar[!grepl("^\\w*$", sidebar)]

    sidebar <- .substitute_altdoc_variables(sidebar, path = path)

    # yaml::write_yaml converts true to yes, but quarto complains
    sidebar <- gsub(": yes$", ": true", sidebar)

    fn <- fs::path_join(c(path, "_quarto", "_quarto.yml"))
    writeLines(sidebar, fn)

    tmp <- fs::path_join(c(path, "_quarto", "docs"))
    for (f in fs::dir_ls(tmp)) {
        fs::file_move(f, fs::path_join(c(path, "_quarto")))
    }
    fs::dir_delete(tmp)

    quarto::quarto_render(input = fs::path_join(c(path, "_quarto")), quiet = !verbose)

    # move _quarto/_site to docs/

}