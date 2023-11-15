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
