.finalize_docute <- function(settings, path, ...) {
    # drop missing entries
    settings <- settings[!grepl("link: ''", settings)]

    fn <- fs::path_join(c(.doc_path(path), "index.html"))
    writeLines(settings, fn)

    # Fix vignette relative links
    vignettes <- list.files(
        fs::path_join(c(.doc_path(path), "vignettes")),
        pattern = "\\.md")
    vignettes <- gsub("\\.md$", "", vignettes)
    for (v in vignettes) {
        fn <- fs::path_join(c(.doc_path(path), "vignettes", paste0(v, ".md")))
        txt <- .readlines(fn)
        txt <- gsub(
            paste0("![](", v),
            paste0("![](vignettes/", v),
            txt,
            fixed = TRUE)
        writeLines(txt, fn)
    }

    # Fix man relative links
    man <- list.files(
        fs::path_join(c(.doc_path(path), "man")),
        pattern = "\\.md")
    man <- gsub("\\.md$", "", man)
    for (v in man) {
        fn <- fs::path_join(c(.doc_path(path), "man", paste0(v, ".md")))
        txt <- .readlines(fn)
        # Quarto problems
        txt <- gsub(
            paste0("![](", v),
            paste0("![](man/", v),
            txt,
            fixed = TRUE)
        writeLines(txt, fn)
    }
}


.sidebar_vignettes_docute <- function(sidebar, path) {
    dn <- fs::path_join(c(.doc_path(path), "vignettes"))
    fn_vignettes <- list.files(dn, pattern = "\\.md$", full.names = TRUE)

    # before gsub on paths
    titles <- sapply(fn_vignettes, .get_vignettes_titles)
    fn_vignettes <- gsub(.doc_path(path), "", fn_vignettes, fixed = TRUE)

    # escape because we enclose in single quotes in the json file
    titles <- gsub("'", "\\\\'", titles)

    # # static assets strict relative path
    # fn_vignettes <- ifelse(tools::file_ext(fn_vignettes) == "pdf",
    #                        paste0(fn_vignettes, "':ignore'"),
    #                        fn_vignettes)

    if (length(fn_vignettes) > 0) {
        tmp <- sprintf("{title: '%s', link: '%s'}", titles, fn_vignettes)
        tmp <- paste(tmp, collapse = ", ")
        sidebar <- paste(sidebar, collapse = "\n")
        if (isTRUE(grepl("\\$ALTDOC_VIGNETTE_BLOCK", sidebar))) {
            sidebar <- gsub("\\$ALTDOC_VIGNETTE_BLOCK", "%s", sidebar)
            sidebar <- sprintf(sidebar, tmp)
        }
        sidebar <- strsplit(sidebar, "\n")[[1]]
    } else {
        sidebar <- sidebar[!grepl("\\$ALTDOC_VIGNETTE_BLOCK", sidebar)]
    }
    return(sidebar)
}


.sidebar_man_docute <- function(sidebar, path) {
    fn_man <- fs::path_join(c(.doc_path(path), "reference.md"))
    dn_man <- fs::path_join(c(.doc_path(path), "man"))
    # multi page
    if (fs::dir_exists(dn_man) && length(fs::dir_ls(dn_man)) > 0) {
        fn_man <- list.files(dn_man, pattern = "\\.md$", full.names = TRUE)
        fn_man <- sapply(fn_man, function(x) fs::path_join(c("/man", basename(x))))
        titles <- fs::path_ext_remove(basename(fn_man))
        tmp <- sprintf("{title: '%s', link: '%s'}", titles, fn_man)
        tmp <- paste(tmp, collapse = ", ")
        sidebar <- paste(sidebar, collapse = "\n")
        if (isTRUE(grepl("\\$ALTDOC_MAN_BLOCK", sidebar))) {
            sidebar <- gsub("\\$ALTDOC_MAN_BLOCK", "%s", sidebar)
            sidebar <- sprintf(sidebar, tmp)
        }
        sidebar <- strsplit(sidebar, "\n")[[1]]
    } else {
        sidebar <- sidebar[!grepl("\\$ALTDOC_MAN_BLOCK", sidebar)]
    }
    return(sidebar)
}
