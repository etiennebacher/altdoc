.create_immutable <- function(path = ".", doctype = "docsify") {
    .check_is_package(path)

    imm_dir <- fs::path_abs(fs::path_join(c(path, "altdoc")))

    if (!fs::dir_exists(imm_dir)) {
        .add_rbuildignore("^altdoc$", path = path)
        fs::dir_create(imm_dir)
    }

    if (isTRUE(doctype == "docsify")) {
        src <- system.file("docsify/index.html", package = "altdoc")
        tar <- fs::path_join(c(imm_dir, "index.html"))
        file.copy(src, tar, overwrite = FALSE)

        src <- system.file("docsify/_sidebar.md", package = "altdoc")
        tar <- fs::path_join(c(imm_dir, "docsify.md"))
        file.copy(src, tar, overwrite = FALSE)

    } else if (isTRUE(doctype == "docute")) {
        src <- system.file("docute/index.html", package = "altdoc")
        tar <- fs::path_join(c(imm_dir, "docute.html"))
        file.copy(src, tar, overwrite = FALSE)
    }

    return(invisible())
}


.substitute_altdoc_variables <- function(x, filename, path = ".") {
    x <- gsub("\\$ALTDOC_VERSION", packageVersion("altdoc"), x)

    # DESCRIPTION file
    fn <- fs::path_join(c(path, "DESCRIPTION"))
    if (fs::file_exists(fn)) {
        x <- gsub("\\$ALTDOC_PACKAGE_NAME", desc::desc_get("Package"), x)
        x <- gsub("\\$ALTDOC_PACKAGE_VERSION", desc::desc_get("Version"), x)
        x <- gsub("\\$ALTDOC_PACKAGE_URL", desc::desc_get_urls()[1], x)
    } else {
        x <- gsub("\\$ALTDOC_PACKAGE_NAME", "", x)
        x <- gsub("\\$ALTDOC_PACKAGE_VERSION", "", x)
        x <- gsub("\\$ALTDOC_PACKAGE_URL", "", x)
    }

    return(x)
}


.import_immutable <- function(path = ".", doctype = "docsify") {

    # copy all files from altdoc/ into docs/
    # this allows users to store arbitrary and immutable static files in altdoc/
    src <- fs::path_abs(fs::path_join(c(path, "altdoc")))
    if (fs::dir_exists(src)) {
        files <- fs::dir_ls(src)

        # wait for .import_immutable() to copy these over
        files <- files[!grepl("docute.html$|docsify.md$|mkdocs.yml$", files)]

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
    fn <- fs::path_join(c(path, "altdoc", "docsify.md"))
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

    ############### Vignettes
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
        sidebar <- gsub("\\$ALTDOC_VIGNETTE_BLOCK", tmp, sidebar)
    } else {
        sidebar <- gsub("\\$ALTDOC_VIGNETTE_BLOCK", "", sidebar)
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
        if (length(fn_man) > 0) {
            tmp <- sprintf("  - [%s](%s)", titles, fn_man)
            tmp <- c("* Reference", tmp)
            tmp <- paste(tmp, collapse = "\n")
            sidebar <- gsub("\\$ALTDOC_MAN_BLOCK", tmp, sidebar)
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

    fn <- gsub("docsify.md$", "_sidebar.md", fn)
    writeLines(sidebar, fn)

}


.import_immutable_docute <- function(path) {
    # Read immutable sidebar
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
    fn_vignettes <- gsub(.doc_path(path), "", fn_vignettes, fixed = TRUE)
    titles <- fs::path_ext_remove(basename(fn_vignettes))
    if (length(fn_vignettes) > 0) {
        tmp <- sprintf("              {title: '%s', link: '/articles/%s'},", titles, titles)
        tmp <- c(
            "          {",
            "           title: 'Articles',",
            "           children:",
            "             [",
            tmp,
            "             ]",
            "          },"
        )
        tmp <- paste(tmp, collapse = "\n")
        sidebar <- gsub("\\$ALTDOC_VIGNETTE_BLOCK", tmp, sidebar)
    } else {
        sidebar <- gsub("\\$ALTDOC_VIGNETTE_BLOCK", "", sidebar)
    }


    ############ Man pages
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
            sidebar <- gsub("\\$ALTDOC_MAN_BLOCK", tmp, sidebar)
        } else {
            sidebar <- gsub("\\$ALTDOC_MAN_BLOCK", "", sidebar)
        }

    # one page
    } else if (fs::file_exists(fn_man)) {
        sidebar <- gsub("\\$ALTDOC_MAN_BLOCK", "* [Reference](reference.md)", sidebar)

    # no man page
    } else {
        sidebar <- gsub("\\$ALTDOC_MAN_BLOCK", "", sidebar)

    }


    # drop missing sidebar entries
    sidebar <- sidebar[!grepl("link: ''", sidebar)]

    sidebar <- .substitute_altdoc_variables(sidebar, path = path)

    # write mutable sidebar
    fn <- gsub("docute.html$", "index.html", fn)
    writeLines(sidebar, fn)
}