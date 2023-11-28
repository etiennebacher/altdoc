.substitute_altdoc_variables <- function(x, filename, path = ".", tool = "docsify") {
    x <- gsub("\\$ALTDOC_VERSION", utils::packageVersion("altdoc"), x)

    for (vn in c("NEWS.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "CONTRIBUTING.md", "LICENSE.md", "LICENCE.md", "CITATION.md")) {
        fn <- fs::path_join(c(.doc_path(path), vn))
        regex <- sprintf("\\$ALTDOC_%s", fs::path_ext_remove(basename(vn)))
        if (fs::file_exists(fn) || fs::file_exists(fs::path_join(c(path, "_quarto/docs", vn)))) {
            if (tool == "docute") {
                new <- paste0("/", vn)
            } else {
                new <- vn
            }
            x <- gsub(regex, new, x)
        } else {
            x <- x[!grepl(regex, x)]
        }
    }

    # DESCRIPTION file
    fn <- fs::path_join(c(path, "DESCRIPTION"))
    if (fs::file_exists(fn)) {

        # before $ALTDOC_PACKAGE_URL
        urls <- c(
            tryCatch(desc::desc_get_urls(), error = function(e) NULL),
            tryCatch(desc::desc_get_field("BugReports"), error = function(e) NULL))
        urls_gh <- Filter(function(x) grepl("github.com", x), urls)
        if (length(urls_gh) > 0) {
            x <- gsub("\\$ALTDOC_PACKAGE_URL_GITHUB", urls_gh[1], x)
        } else {
            x <- x[!grepl("\\$ALTDOC_PACKAGE_URL_GITHUB", x)]
        }

        if (length(urls) > 0) {
            x <- gsub("\\$ALTDOC_PACKAGE_URL", urls[1], x)
        } else {
            x <- x[!grepl("\\$ALTDOC_PACKAGE_URL", x)]
        }

        x <- gsub("\\$ALTDOC_PACKAGE_NAME", desc::desc_get("Package"), x)
        x <- gsub("\\$ALTDOC_PACKAGE_VERSION", desc::desc_get("Version"), x)


    } else {
        x <- gsub("\\$ALTDOC_PACKAGE_NAME", "", x)
        x <- gsub("\\$ALTDOC_PACKAGE_VERSION", "", x)
        x <- x[grepl("\\$ALTDOC_PACKAGE_URL_GITHUB")] # before the other one
        x <- gsub("\\$ALTDOC_PACKAGE_URL", "", x)
    }

    # some commands expand the full path
    x <- gsub(.doc_path(path), "", x, fixed = TRUE)

    return(x)
}
