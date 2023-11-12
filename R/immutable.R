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
        # Read immutable sidebar
        fn <- fs::path_join(c(.doc_path(path), "_sidebar.md"))
        sidebar <- readLines(fn)

        # Single files
        sidebar <- gsub("\\$ALTDOC_MAN", "reference.md", sidebar)
        sidebar <- gsub("\\$ALTDOC_NEWS", "NEWS.md", sidebar)
        sidebar <- gsub("\\$ALTDOC_LICENSE", "LICENSE.md", sidebar)
        sidebar <- gsub("\\$ALTDOC_CODE_OF_CONDUCT", "CODE_OF_CONDUCT.md", sidebar)

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
            sidebar <- gsub("\\$ALTDOC_VIGNETTES", tmp, sidebar)
        }

        writeLines(sidebar, fn)

    } else if (isTRUE(doctype == "docute")) {
        sidebar <- fs::path_join(c(.doc_path(path), "index.html"))
        sidebar <- readLines(sidebar)
    }


}
