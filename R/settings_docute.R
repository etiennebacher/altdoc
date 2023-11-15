.import_settings_docute <- function(path) {
    # Read settings sidebar
    fn <- fs::path_join(c(path, "altdoc", "docute.html"))
    sidebar <- readLines(fn)

    # Single files
    if (fs::file_exists(fs::path_join(c(.doc_path(path), "NEWS.md")))) {
        sidebar <- gsub("\\$ALTDOC_NEWS", "/NEWS", sidebar)
    } else {
        sidebar <- gsub("\\$ALTDOC_NEWS", "", sidebar)
    }

    if (fs::file_exists(fs::path_join(c(.doc_path(path), "LICENSE.md")))) {
        sidebar <- gsub("\\$ALTDOC_LICENSE", "/LICENSE", sidebar)
    } else {
        sidebar <- gsub("\\$ALTDOC_LICENSE", "", sidebar)
    }

    if (fs::file_exists(fs::path_join(c(.doc_path(path), "CODE_OF_CONDUCT.md")))) {
        sidebar <- gsub("\\$ALTDOC_CODE_OF_CONDUCT", "/CODE_OF_CONDUCT", sidebar)
    } else {
        sidebar <- gsub("\\$ALTDOC_CODE_OF_CONDUCT", "", sidebar)
    }


    ############### Vignettes
    # TODO: get clean titles. .get_vignettes_titles does not work as I expected
    dn1 <- fs::path_join(c(.doc_path(path), "vignettes"))
    dn2 <- fs::path_join(c(.doc_path(path), "articles"))
    fn_vignettes <- c(
        list.files(dn1, pattern = "\\.md$", full.names = TRUE),
        list.files(dn2, pattern = "\\.md$", full.names = TRUE)
    )
    # before gsub on paths
    titles <- sapply(fn_vignettes, .get_vignettes_titles)
    fn_vignettes <- gsub(.doc_path(path), "", fn_vignettes, fixed = TRUE)

    # escape because we enclose in single quotes in the json file
    titles <- gsub("'", "\\\\'", titles)

    if (length(fn_vignettes) > 0) {
        tmp <- sprintf("{title: '%s', link: '%s'}", titles, fn_vignettes)
        tmp <- paste(tmp, collapse = ", ")
        sidebar <- paste(sidebar, collapse = "\n")
        sidebar <- gsub("\\$ALTDOC_VIGNETTE_BLOCK", "%s", sidebar)
        sidebar <- sprintf(sidebar, tmp)
        sidebar <- strsplit(sidebar, "\n")[[1]]

    } else {
        sidebar <- sidebar[!grepl("\\$ALTDOC_VIGNETTE_BLOCK", sidebar)]
    }


    ############ Man pages
    fn_man <- fs::path_join(c(.doc_path(path), "reference.md"))
    dn_man <- fs::path_join(c(.doc_path(path), "man"))

    # multi page
    if (fs::dir_exists(dn_man)) {
        fn_man <- list.files(dn_man, pattern = "\\.md$", full.names = TRUE)
        fn_man <- sapply(fn_man, function(x) fs::path_join(c("man", basename(x))))
        titles <- fs::path_ext_remove(basename(fn_man))
        tmp <- sprintf("{title: '%s', link: '%s'}", titles, fn_man)
        tmp <- paste(tmp, collapse = ", ")
        sidebar <- paste(sidebar, collapse = "\n")
        sidebar <- gsub("\\$ALTDOC_MAN_BLOCK", "%s", sidebar)
        sidebar <- sprintf(sidebar, tmp)
        sidebar <- strsplit(sidebar, "\n")[[1]]

    } else {
        sidebar <- sidebar[!grepl("\\$ALTDOC_MAN_BLOCK", sidebar)]
    }

    # drop missing sidebar entries
    sidebar <- sidebar[!grepl("link: ''", sidebar)]

    sidebar <- .substitute_altdoc_variables(sidebar, path = path)

    # write mutable sidebar
    fn <- fs::path_join(c(.doc_path(path), "index.html"))
    writeLines(sidebar, fn)
}