.create_immutable <- function(path = ".", doctype = "docute") {
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


.import_immutable <- function(path = ".") {
    src <- fs::path_abs(fs::path_join(c(path, "altdoc")))
    if (fs::dir_exists(src)) {
        files <- fs::dir_ls(src)
        # docs/* files are mutable and should be overwritten
        for (src in files) {
            tar <- fs::path_join(c(.doc_path(path), basename(src)))
            fs::file_copy(src, .doc_path(path), overwrite = TRUE)
        }
    }
}
