.import_settings_quarto_website <- function(path, verbose = FALSE) {
    # Read settings sidebar
    fn <- fs::path_join(c(path, "altdoc", "quarto_website.yml"))
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
    ## TODO move code below to separate internal functions, e.g `generate_vignettes()`, `generate_man()`

    ############### Vignettes
    # TODO: get clean titles. .get_vignettes_titles does not work as I expected
    fn_vignettes <- list.files(
        fs::path_join(c(.doc_path(path), "vignettes")),
        pattern = "\\.qmd$", full.names = TRUE)
    fn_man <- list.files(
        fs::path_join(c(.doc_path(path), "man")),
        pattern = "\\.qmd$", full.names = TRUE)
    fn_vignettes <- gsub(paste0(.doc_path(path), "/"), "", fn_vignettes, fixed = TRUE)
    fn_man <- gsub(paste0(.doc_path(path), "/"), "", fn_man, fixed = TRUE)

    yml <- paste(sidebar, collapse = "\n")
    yml <- yaml::yaml.load(yml)

    for (i in seq_along(yml$website$sidebar$contents)) {
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

    

    if (fs::file_exists(fs::path_join(c(.doc_path(path), "CODE_OF_CONDUCT.md")))) {
        sidebar <- gsub("\\$ALTDOC_CODE_OF_CONDUCT", "CODE_OF_CONDUCT.md", sidebar)
    } else {
        sidebar <- gsub("\\$ALTDOC_CODE_OF_CONDUCT", "", sidebar)
    }
    ### TODO move code below to separate internal functions, e.g `generate_vignettes()`, `generate_man()`  

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

    fn <- fs::path_join(c(.doc_path(path), "_quarto.yml"))
    writeLines(sidebar, fn)

    quarto::quarto_render(input = .doc_path(path), quiet = !verbose)

}


