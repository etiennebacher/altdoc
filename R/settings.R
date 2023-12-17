.import_settings <- function(verbose = FALSE, freeze = FALSE) {

    tool <- .doc_type()

    # copy all files from altdoc/ into docs/
    # this allows users to store arbitrary and settings static files in altdoc/
    src <- fs::path_abs("altdoc")
    if (fs::dir_exists(src)) {
        files <- fs::dir_ls(src)

        files <- files[!grepl("freeze.rds$", files)]

        # hidden files not detected
        if (fs::file_exists("altdoc/.nojekyll")) {
            files <- c(files, "altdoc/.nojekyll")
        }

        files <- files[!grepl("docute.html$|docsify.md$|mkdocs.yml$", files)]

        # docs/* files are mutable and should be overwritten
        if (grepl("^quarto", tool)) {
            tar_dir <- "_quarto/docs" 
        } else {
            tar_dir <- "docs"
        }

        fs::dir_copy(src, tar_dir, overwrite = TRUE)
    }

    fn <- switch(tool,
        docsify = "docsify.md",
        docute = "docute.html",
        mkdocs = "mkdocs.yml",
        quarto_website = "quarto_website.yml")
    fn <- fs::path_join(c("altdoc", fn))
    settings <- .readlines(fn)

    settings <- .substitute_altdoc_variables(settings, tool = tool)

    vignettes <- switch(tool,
        docsify = .sidebar_vignettes_docsify,
        docute = .sidebar_vignettes_docute,
        mkdocs = .sidebar_vignettes_mkdocs,
        quarto_website = .sidebar_vignettes_quarto_website)
    settings <- vignettes(sidebar = settings)

    man <- switch(tool,
        docsify = .sidebar_man_docsify,
        docute = .sidebar_man_docute,
        mkdocs = .sidebar_man_mkdocs,
        quarto_website = .sidebar_man_quarto_website)
    settings <- man(settings)

    finalize <- switch(tool,
        docsify = .finalize_docsify,
        docute = .finalize_docute,
        mkdocs = .finalize_mkdocs,
        quarto_website = .finalize_quarto_website)
    settings <- finalize(settings, verbose, freeze)

    cli::cli_alert_success("HTML updated.")
}