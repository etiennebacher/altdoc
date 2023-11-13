.import_settings_mkdocs <- function(path) {
    # Read settings sidebar
    fn <- fs::path_join(c(path, "altdoc", "mkdocs.yml"))
    sidebar <- readLines(fn, warn = FALSE)

    # Single files
    if (fs::file_exists(fs::path_join(c(.doc_path(path), "NEWS.md")))) {
        sidebar <- gsub("\\$ALTDOC_NEWS", "NEWS.md", sidebar)
    } else {
        sidebar <- sidebar[!grepl(".*\\$ALTDOC_NEWS", sidebar)]
    }

    if (fs::file_exists(fs::path_join(c(.doc_path(path), "LICENSE.md")))) {
        sidebar <- gsub("\\$ALTDOC_LICENSE", "LICENSE.md", sidebar)
    } else {
        sidebar <- sidebar[!grepl(".*\\$ALTDOC_LICENSE", sidebar)]
    }

    if (fs::file_exists(fs::path_join(c(.doc_path(path), "CODE_OF_CONDUCT.md")))) {
        sidebar <- gsub("\\$ALTDOC_CODE_OF_CONDUCT", "CODE_OF_CONDUCT.md", sidebar)
    } else {
        sidebar <- sidebar[!grepl(".*\\$ALTDOC_CODE_OF_CONDUCT", sidebar)]
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
    fn_vignettes <- sapply(fn_vignettes, function(x) 
        {
            fs::path_join(c("articles", basename(x)))
        }
    )
    if (length(fn_vignettes) > 0) {
        tmp <- sprintf("      - %s: %s", titles, fn_vignettes)
        tmp <- c("  - Articles:", tmp)
        tmp <- paste(tmp, collapse = "\n")
        sidebar <- gsub("\\$ALTDOC_VIGNETTE_BLOCK", tmp, sidebar)
    } else {
        sidebar <- gsub("\\$ALTDOC_VIGNETTE_BLOCK", "", sidebar)
    }


    ########## Man pages
    fn_man <- fs::path_join(c(.doc_path(path), "reference.md"))
    dn_man <- fs::path_join(c(.doc_path(path), "man"))

    # multi page
    if (fs::dir_exists(dn_man)) {
        fn_man <- list.files(dn_man, pattern = "\\.md$", full.names = TRUE)
        fn_man <- sapply(fn_man, function(x) fs::path_join(c("man", basename(x))))
        titles <- fs::path_ext_remove(basename(fn_man))
        tmp <- sprintf("      - %s: man/%s", titles, titles)
        tmp <- c("  - Reference:", tmp)
        tmp <- paste(tmp, collapse = "\n")
        sidebar <- gsub("\\$ALTDOC_MAN_BLOCK", tmp, sidebar)

    # one page
    } else if (fs::file_exists(fn_man)) {
        sidebar <- gsub("\\$ALTDOC_MAN_BLOCK", "  - Reference: reference.md", sidebar)

    # no man page
    } else {
        sidebar <- gsub("\\$ALTDOC_MAN_BLOCK", "", sidebar)

    }

    sidebar <- .substitute_altdoc_variables(sidebar, path = path)

    # write mutable sidebar
    fn <- fs::path_join(c(path, "mkdocs.yml"))
    writeLines(sidebar, fn)
}