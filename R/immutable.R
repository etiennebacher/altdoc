.create_immutable <- function(path = ".", doctype = "docsify") {
    .check_is_package(path)

    imm_dir <- fs::path_abs(fs::path_join(c(path, "altdoc")))

    if (!fs::dir_exists(imm_dir)) {
        .add_rbuildignore("^altdoc$", path = path)
        fs::dir_create(imm_dir)
    }

    if (isTRUE(doctype == "docsify")) {
        src <- system.file("docsify/_sidebar.md", package = "altdoc")
        tar <- fs::path_join(c(imm_dir, "_sidebar.md"))
        file.copy(src, tar, overwrite = FALSE)
        src <- system.file("docsify/index.html", package = "altdoc")
        tar <- fs::path_join(c(imm_dir, "index.html"))
        file.copy(src, tar, overwrite = FALSE)

    } else if (isTRUE(doctype == "docute")) {
        src <- system.file("docute/index.html", package = "altdoc")
        tar <- fs::path_join(c(imm_dir, "index.html"))
        file.copy(src, tar, overwrite = FALSE)
    }

    return(invisible())
}


.import_immutable <- function(path = ".", doctype = "docsify") {

    # copy all files from altdoc/ into docs/
    # this allows users to store arbitrary and immutable static files in altdoc/
    src <- fs::path_abs(fs::path_join(c(path, "altdoc")))
    if (fs::dir_exists(src)) {
        files <- fs::dir_ls(src)
        # docs/* files are mutable and should be overwritten
        for (src in files) {
            tar <- fs::path_join(c(.doc_path(path), basename(src)))
            file.copy(src, .doc_path(path), overwrite = TRUE, recursive = TRUE)
        }
    }

    if (isTRUE(doctype == "docsify")) {
        .import_immutable_docsify(path = path)

    } else if (isTRUE(doctype == "docute")) {
        .import_immutable_docute(path = path)
    }
}


.import_immutable_docsify <- function(path) {
    # Read immutable sidebar
    fn <- fs::path_join(c(.doc_path(path), "_sidebar.md"))
    sidebar <- readLines(fn)

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

    # Vignettes
    # TODO: get clean titles. .get_vignettes_titles does not work as I expected
    dn1 <- fs::path_join(c(.doc_path(path), "vignettes"))
    dn2 <- fs::path_join(c(.doc_path(path), "articles"))
    fn_vignettes <- c(
        list.files(dn1, pattern = "\\.md$", full.names = TRUE),
        list.files(dn2, pattern = "\\.md$", full.names = TRUE)
    )
    fn_vignettes <- gsub(.doc_path(path), "", fn_vignettes, fixed = TRUE)
    titles <- fs::path_ext_remove(basename(fn_vignettes))
    if (length(fn_vignettes) > 0) {
        tmp <- sprintf("  - [%s](%s)", titles, fn_vignettes)
        tmp <- c("* Articles", tmp)
        tmp <- paste(tmp, collapse = "\n")
        sidebar <- gsub("\\$ALTDOC_VIGNETTES_LIST", tmp, sidebar)
    }

    # Man pages
    fn_man <- fs::path_join(c(.doc_path(path), "reference.md"))
    dn_man <- fs::path_join(c(.doc_path(path), "man"))

    # multi page
    if (fs::dir_exists(dn_man)) {
        fn_man <- list.files(dn_man, pattern = "\\.md$", full.names = TRUE)
        fn_man <- sapply(fn_man, function(x) fs::path_join(c("man", basename(x))))
        fn_man <- sapply(fn_man, fs::path_ext_remove)
        titles <- fs::path_ext_remove(basename(fn_man))
        if (length(fn_man) > 0) {
            tmp <- sprintf("  - [%s](%s)", titles, fn_man)
            tmp <- c("* Reference", tmp)
            tmp <- paste(tmp, collapse = "\n")
            sidebar <- gsub("\\$ALTDOC_MAN_LIST", tmp, sidebar)
        }

    # one page
    } else if (fs::file_exists(fn_man)) {
        sidebar <- gsub("\\$ALTDOC_MAN_LIST", "{title: 'Reference', link: ''},", sidebar)

    }

    # drop missing sidebar entries
    sidebar <- gsub("\\* \\[.*\\]\\(\\)$", "", sidebar)

    # drop empty lines
    sidebar <- sidebar[!grepl("^\\w*$", sidebar)]

    writeLines(sidebar, fn)
}


.import_immutable_docute <- function(path) {
    # Read immutable sidebar
    fn <- fs::path_join(c(.doc_path(path), "index.html"))
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

    # Man pages
    fn_man <- fs::path_join(c(.doc_path(path), "reference.md"))
    dn_man <- fs::path_join(c(.doc_path(path), "man"))

    # multi page
    if (fs::dir_exists(dn_man)) {
        fn_man <- list.files(dn_man, pattern = "\\.md$", full.names = TRUE)
        fn_man <- sapply(fn_man, function(x) fs::path_join(c("man", basename(x))))
        titles <- fs::path_ext_remove(basename(fn_man))
        if (length(fn_man) > 0) {
            tmp <- sprintf("              {title: '%s', link: '/man/%s'},", titles, titles)
            tmp <- c(
                "          {",
                "           title: 'Reference',",
                "           children:",
                "             [",
                tmp,
                "             ]",
                "          },"
            )
            tmp <- paste(tmp, collapse = "\n")
            sidebar <- gsub("\\$ALTDOC_MAN_LIST", tmp, sidebar)
        }

    # one page
    } else if (fs::file_exists(fn_man)) {
        sidebar <- gsub("\\$ALTDOC_MAN_LIST", "* [Reference](reference.md)", sidebar)
    }

    # drop missing sidebar entries
    sidebar <- sidebar[!grepl("link: ''", sidebar)]

    # write mutable sidebar
    writeLines(sidebar, fn)
}