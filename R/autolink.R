.autolink <- function(path = ".") {
    html_files <- c(tryCatch(fs::dir_ls(fs::path_join(c(path, "docs/vignettes")), regexp = "\\.html$"), error = function(e) NULL),
                    tryCatch(fs::dir_ls(fs::path_join(c(path, "docs/man")), regexp = "\\.html$"), error = function(e) NULL))
    for (h in html_files) {
        downlit::downlit_html_path(h, h)
    }
    # h <- fs::path_join(c(path, "docs/index.html"))
    # if (fs::file_exists(h)) {
    #     downlit::downlit_html_path(h, h)
    # }

    md_files <- c(
        tryCatch(fs::dir_ls(fs::path_join(c(path, "docs/vignettes")), regexp = "\\.md$"), error = function(e) NULL),
        tryCatch(fs::dir_ls(fs::path_join(c(path, "docs/man")), regexp = "\\.md$"), error = function(e) NULL))
    for (m in md_files) {
        downlit::downlit_md_path(m, m)
    }
    # m <- fs::path_join(c(path, "docs/README.md"))
    # if (fs::file_exists(m)) {
    #     downlit::downlit_html_path(m, m)
    # }
}
