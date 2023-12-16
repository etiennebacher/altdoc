.finalize_docsify <- function(settings, path, ...) {

    tool <- .doc_type(path)

    # drop missing links
    settings <- settings[!grepl("\\]\\(\\)", settings)]
    settings <- stats::na.omit(settings)

    fn_man <- fs::path_join(c(.doc_path(path), "reference.md"))
    dn_man <- fs::path_join(c(.doc_path(path), "man"))


    fn <- fs::path_join(c(.doc_path(path), "_sidebar.md"))
    writeLines(settings, fn)

    # relative links
    dn <- fs::path_join(c(path, "docs", "vignettes"))
    if (fs::dir_exists(dn)) {
        md_files <- fs::dir_ls(dn, regexp = "\\.md$")
        for (md in md_files) {
            src <- sprintf('src="%s.markdown_strict_files', gsub("\\.md$|\\.pdf$", "", basename(md)))
            tar <- sprintf('src="vignettes/%s.markdown_strict_files', gsub("\\.md$|\\.pdf$", "", basename(md)))
            content <- gsub(src, tar, .readlines(md), fixed = TRUE)
            writeLines(content, md)
        }
    }

    # body also includes altdoc variables
    fn <- fs::path_join(c(path, "altdoc", "docsify.html"))
    body <- .readlines(fn)
    body <- .substitute_altdoc_variables(body, path = path, tool = tool)
    fn <- fs::path_join(c(.doc_path(path), "index.html"))
    writeLines(body, fn)
}


.sidebar_vignettes_docsify <- function(sidebar, path) {
    dn <- fs::path_join(c(.doc_path(path), "vignettes"))
    fn_vignettes <- list.files(dn, pattern = "\\.md$|\\.pdf$", full.names = TRUE)
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
            tmp <- ifelse(
                tools::file_ext(fn_vignettes) == "pdf",
                sprintf("%s  - [%s](%s ':ignore')", indent, titles, fn_vignettes),
                sprintf("%s  - [%s](%s)", indent, titles, fn_vignettes))
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

        if (length(fn) > 0) {
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
        } else {
            sidebar <- sidebar[!grepl("\\$ALTDOC_MAN_BLOCK", sidebar)]
        }
    } else {
        sidebar <- sidebar[!grepl("\\$ALTDOC_MAN_BLOCK", sidebar)]
    }
    return(sidebar)
}
