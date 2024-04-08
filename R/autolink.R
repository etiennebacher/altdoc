.autolink <- function(path = ".") {
    # everything wrapped in tryCatch() because especially error prone with weird pandoc memory errors
    html_files <- c(
        fs::dir_ls(fs::path_join(c(path, "docs/vignettes")), regexp = "\\.html$", fail = FALSE),
        fs::dir_ls(fs::path_join(c(path, "docs/man")), regexp = "\\.html$", fail = FALSE))
    for (h in html_files) {
        tmp <- try(downlit::downlit_html_path(h, h), silent = TRUE)
        if (inherits(tmp, "try-error")) {
            cli::cli_alert_danger(sprintf("Failed to auto-link: %s", h))
        }
    }

    md_files <- c(
        fs::dir_ls(fs::path_join(c(path, "docs/vignettes")), regexp = "\\.md$", fail = FALSE),
        fs::dir_ls(fs::path_join(c(path, "docs/man")), regexp = "\\.md$", fail = FALSE))
    for (m in md_files) {
        tmp <- try(downlit::downlit_md_path(m, m), silent = TRUE)
        if (inherits(tmp, "try-error")) {
            cli::cli_alert_danger(sprintf("Failed to auto-link: %s", h))
        }
    }
}
