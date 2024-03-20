.import_settings <- function(path = ".", tool = "docsify", verbose = FALSE, freeze = FALSE) {

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
        if (grepl("^quarto", tool)) {
            tar_dir <- fs::path_join(c(path, "_quarto"))
        } else {
            tar_dir <- .doc_path(path)
        }

        fs::dir_copy(src, tar_dir, overwrite = TRUE)
    }

    fn <- switch(tool,
        docsify = "docsify.md",
        docute = "docute.html",
        mkdocs = "mkdocs.yml",
        quarto_website = "quarto_website.yml")
    fn <- fs::path_join(c(path, "altdoc", fn))
    settings <- .readlines(fn)

    settings <- .substitute_altdoc_variables(settings, path = path, tool = tool)

    vignettes <- switch(tool,
        docsify = .sidebar_vignettes_docsify,
        docute = .sidebar_vignettes_docute,
        mkdocs = .sidebar_vignettes_mkdocs,
        quarto_website = .sidebar_vignettes_quarto_website)
    settings <- vignettes(sidebar = settings, path = path)

    man <- switch(tool,
        docsify = .sidebar_man_docsify,
        docute = .sidebar_man_docute,
        mkdocs = .sidebar_man_mkdocs,
        quarto_website = .sidebar_man_quarto_website)
    settings <- man(settings, path)

    finalize <- switch(tool,
        docsify = .finalize_docsify,
        docute = .finalize_docute,
        mkdocs = .finalize_mkdocs,
        quarto_website = .finalize_quarto_website)
    settings <- finalize(settings, path, verbose, freeze)

    cli::cli_alert_success("HTML updated.")
}
