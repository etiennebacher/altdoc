.finalize_docsify <- function(settings, path, ...) {
    # drop missing links
    settings <- settings[!grepl("\\]\\(\\)", settings)]
    settings <- stats::na.omit(settings)

    fn_man <- fs::path_join(c(.doc_path(path), "reference.md"))
    dn_man <- fs::path_join(c(.doc_path(path), "man"))


    fn <- fs::path_join(c(.doc_path(path), "_sidebar.md"))
    writeLines(settings, fn)

    # body also includes altdoc variables
    fn <- fs::path_join(c(path, "altdoc", "docsify.html"))
    body <- .readlines(fn)
    body <- .substitute_altdoc_variables(body, path = path)
    fn <- fs::path_join(c(.doc_path(path), "index.html"))
    writeLines(body, fn)
}


.sidebar_vignettes_docsify <- function(sidebar, path) {
    dn <- fs::path_join(c(.doc_path(path), "vignettes"))
    fn_vignettes <- list.files(dn, pattern = "\\.md$", full.names = TRUE)
    # before gsub on files
    titles <- sapply(fn_vignettes, .get_vignettes_titles)
    fn_vignettes <- sapply(fn_vignettes, function(x) {
        fs::path_join(c("vignettes", basename(x)))
    })
    if (length(fn_vignettes) > 0) {
        idx <- grep("\\$ALTDOC_VIGNETTE_BLOCK", sidebar)
        if (length(idx) == 1) {
            sidebar <- gsub("\\$ALTDOC_VIGNETTE_BLOCK", "", sidebar)
            indent <- gsub("^(\\w*).*", "\\1", sidebar[idx])
            tmp <- sprintf("%s  - [%s](%s)", indent, titles, fn_vignettes)
            sidebar <- c(sidebar[1:idx], tmp, sidebar[(idx + 1):length(sidebar)])
        }
    } else {
        sidebar <- sidebar[!grepl("\\$ALTDOC_VIGNETTE_BLOCK", sidebar)]
    }
    return(sidebar)
}


.sidebar_man_docsify <- function(sidebar, path) {
    dn <- fs::path_join(c(.doc_path(path), "man"))
    if (fs::dir_exists(dn)) {
        fn <- list.files(dn, pattern = "\\.md$", full.names = TRUE)
        fn <- sapply(fn, function(x) fs::path_join(c("man", basename(x))))
        fn <- sapply(fn, fs::path_ext_remove)
        titles <- fs::path_ext_remove(basename(fn))
        idx <- grep("\\$ALTDOC_MAN_BLOCK", sidebar)
        if (length(idx) == 1) {
            sidebar <- gsub("\\$ALTDOC_MAN_BLOCK", "", sidebar)
            indent <- gsub("^(\\w*).*", "\\1", sidebar[idx])
            tmp <- sprintf("%s  - [%s](%s)", indent, titles, fn)
            sidebar <- c(sidebar[1:idx], tmp, sidebar[(idx + 1):length(sidebar)])
        } else {
            sidebar <- sidebar[!grepl("\\$ALTDOC_MAN_BLOCK", sidebar)]
        }
    }
    return(sidebar)
}