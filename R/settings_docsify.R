.import_settings_docsify <- function(path) {
    # Read settings sidebar
    fn <- fs::path_join(c(path, "altdoc", "docsify.md"))
    sidebar <- .readlines(fn)

    # Single files
    if (fs::file_exists(fs::path_join(c(.doc_path(path), "NEWS.md")))) {
        sidebar <- gsub("\\$ALTDOC_NEWS", "NEWS.md", sidebar)
    } else {
        sidebar <- gsub("\\$ALTDOC_NEWS", "", sidebar)
    }

    if (fs::file_exists(fs::path_join(c(.doc_path(path), "LICENSE.md")))) {
        sidebar <- gsub("\\$ALTDOC_LICENSE", "LICENSE.md", sidebar)
    } else {
        sidebar <- gsub("\\$ALTDOC_LICENSE", "", sidebar)
    }

    if (fs::file_exists(fs::path_join(c(.doc_path(path), "CODE_OF_CONDUCT.md")))) {
        sidebar <- gsub("\\$ALTDOC_CODE_OF_CONDUCT", "CODE_OF_CONDUCT.md", sidebar)
    } else {
        sidebar <- gsub("\\$ALTDOC_CODE_OF_CONDUCT", "", sidebar)
    }
    ### TODO move code below to separate internal functions, e.g `generate_vignettes()`, `generate_man()`  


    ############### Vignettes
    # TODO: get clean titles. .get_vignettes_titles does not work as I expected
    dn <- fs::path_join(c(.doc_path(path), "vignettes"))
    fn_vignettes <- list.files(dn, pattern = "\\.md$", full.names = TRUE)

    # before gsub on files
    titles <- sapply(fn_vignettes, .get_vignettes_titles)
    fn_vignettes <- sapply(fn_vignettes, function(x) 
        {
            fs::path_join(c("vignettes", basename(x)))
        }
    )
    if (length(fn_vignettes) > 0) {
        idx <- grep("\\$ALTDOC_VIGNETTE_BLOCK", sidebar)
        if (length(idx) == 1) {
            sidebar <- gsub("\\$ALTDOC_VIGNETTE_BLOCK", "", sidebar)
            indent <- gsub("^(\\w*).*", "\\1", sidebar[idx])
            tmp <- sprintf("%s  - [%s](%s)", indent, titles, fn_vignettes)
            sidebar <- c(sidebar[1:idx], tmp, sidebar[(idx + 1):length(tmp)])
        }
    } else {
        sidebar <- sidebar[!grepl("\\$ALTDOC_VIGNETTE_BLOCK", sidebar)]
    }

    ################### Man pages
    fn_man <- fs::path_join(c(.doc_path(path), "reference.md"))
    dn_man <- fs::path_join(c(.doc_path(path), "man"))

    # multi page
    if (fs::dir_exists(dn_man)) {
        fn_man <- list.files(dn_man, pattern = "\\.md$", full.names = TRUE)
        fn_man <- sapply(fn_man, function(x) fs::path_join(c("man", basename(x))))
        fn_man <- sapply(fn_man, fs::path_ext_remove)
        titles <- fs::path_ext_remove(basename(fn_man))

        idx <- grep("\\$ALTDOC_MAN_BLOCK", sidebar)
        if (length(idx) == 1) {
            sidebar <- gsub("\\$ALTDOC_MAN_BLOCK", "", sidebar)
            indent <- gsub("^(\\w*).*", "\\1", sidebar[idx])
            tmp <- sprintf("%s  - [%s](%s)", indent, titles, fn_man)
            sidebar <- c(sidebar[1:idx], tmp, sidebar[(idx + 1):length(tmp)])
        } else {
            sidebar <- sidebar[!grepl("\\$ALTDOC_MAN_BLOCK", sidebar)]
        }

    # one page
    } else if (fs::file_exists(fn_man)) {
        sidebar <- gsub("\\$ALTDOC_MAN_BLOCK", "{title: 'Reference', link: ''},", sidebar)
    }

    # drop missing sidebar entries
    sidebar <- gsub("\\* \\[.*\\]\\(\\)$", "", sidebar)

    # drop empty lines
    sidebar <- sidebar[!grepl("^\\w*$", sidebar)]

    sidebar <- .substitute_altdoc_variables(sidebar, path = path)

    fn <- fs::path_join(c(.doc_path(path), "_sidebar.md"))
    writeLines(sidebar, fn)

    # body also includes altdoc variables
    fn <- fs::path_join(c(path, "altdoc", "docsify.html"))
    body <- .readlines(fn)
    body <- .substitute_altdoc_variables(body, path = path)
    fn <- fs::path_join(c(.doc_path(path), "index.html"))
    writeLines(body, fn)
}


