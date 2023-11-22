.import_settings <- function(path = ".", doctype = "docsify", verbose = FALSE) {

    # copy all files from altdoc/ into docs/
    # this allows users to store arbitrary and settings static files in altdoc/
    src <- fs::path_abs(fs::path_join(c(path, "altdoc")))
    if (fs::dir_exists(src)) {
        files <- fs::dir_ls(src)

        files <- files[!grepl("freeze.rds$", files)]

        # hidden files not detected
        fn <- fs::path_join(c(path, "altdoc/.nojekyll"))
        if (fs::file_exists(fn)) {
            files <- c(files, fn)
        }

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

    } else if (isTRUE(doctype == "quarto_website")) {
        .import_settings_quarto_website(path = path, verbose = verbose)
    }

    cli::cli_alert_success("HTML updated.")

}
