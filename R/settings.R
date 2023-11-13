.create_settings <- function(path = ".", doctype = "docsify") {
    .check_is_package(path)

    imm_dir <- fs::path_abs(fs::path_join(c(path, "altdoc")))

    # .Rbuildignore directories that would break CRAN submissions
    .add_rbuildignore("^docs$", path = path)
    if (!fs::dir_exists(imm_dir)) {
        .add_rbuildignore("^altdoc$", path = path)
        fs::dir_create(imm_dir)
    }

    if (isTRUE(doctype == "docsify")) {
        src <- system.file("docsify/docsify.html", package = "altdoc")
        tar <- fs::path_join(c(imm_dir, "docsify.html"))
        file.copy(src, tar, overwrite = FALSE)

        src <- system.file("docsify/docsify.md", package = "altdoc")
        tar <- fs::path_join(c(imm_dir, "docsify.md"))
        file.copy(src, tar, overwrite = FALSE)

    } else if (isTRUE(doctype == "docute")) {
        src <- system.file("docute/docute.html", package = "altdoc")
        tar <- fs::path_join(c(imm_dir, "docute.html"))
        file.copy(src, tar, overwrite = FALSE)

    } else if (isTRUE(doctype == "mkdocs")) {
        src <- system.file("mkdocs/mkdocs.yml", package = "altdoc")
        tar <- fs::path_join(c(imm_dir, "mkdocs.yml"))
        file.copy(src, tar, overwrite = FALSE)
    }

    # README.md is mandatory, so we create it automatically
    fn <- fs::path_join(c(path, "README.md"))
    if (!fs::file_exists(fn)) {
        writeLines("Hello World!", fn)
    }


    return(invisible())
}


.substitute_altdoc_variables <- function(x, filename, path = ".") {
    x <- gsub("\\$ALTDOC_VERSION", packageVersion("altdoc"), x)

    # DESCRIPTION file
    fn <- fs::path_join(c(path, "DESCRIPTION"))
    if (fs::file_exists(fn)) {

        # before $ALTDOC_PACKAGE_URL
        urls <- desc::desc_get_urls()
        urls <- Filter(function(x) grepl("github.com", x), urls)
        if (length(urls) > 0) {
            x <- gsub("\\$ALTDOC_PACKAGE_URL_GITHUB", urls[1], x)
        } else {
            x <- x[grepl("\\$ALTDOC_PACKAGE_URL_GITHUB", x)]
        }

        x <- gsub("\\$ALTDOC_PACKAGE_NAME", desc::desc_get("Package"), x)
        x <- gsub("\\$ALTDOC_PACKAGE_VERSION", desc::desc_get("Version"), x)
        x <- gsub("\\$ALTDOC_PACKAGE_URL", desc::desc_get_urls()[1], x)


    } else {
        x <- gsub("\\$ALTDOC_PACKAGE_NAME", "", x)
        x <- gsub("\\$ALTDOC_PACKAGE_VERSION", "", x)
        x <- x[grepl("\\$ALTDOC_PACKAGE_URL_GITHUB")] # before the other one
        x <- gsub("\\$ALTDOC_PACKAGE_URL", "", x)
    }

    return(x)
}


.import_settings <- function(path = ".", doctype = "docsify") {

    # copy all files from altdoc/ into docs/
    # this allows users to store arbitrary and settings static files in altdoc/
    src <- fs::path_abs(fs::path_join(c(path, "altdoc")))
    if (fs::dir_exists(src)) {
        files <- fs::dir_ls(src)

        # wait for .import_settings() to copy these over
        files <- files[!grepl("docute.html$|docsify.md$|mkdocs.yml$", files)]

        # docs/* files are mutable and should be overwritten
        for (src in files) {
            tar <- fs::path_join(c(.doc_path(path), basename(src)))
            file.copy(src, .doc_path(path), overwrite = TRUE, recursive = TRUE)
        }
    }

    if (isTRUE(doctype == "docsify")) {
        .import_settings_docsify(path = path)

    } else if (isTRUE(doctype == "docute")) {
        .import_settings_docute(path = path)

    } else if (isTRUE(doctype == "mkdocs")) {
        .import_settings_mkdocs(path = path)
    }

}


