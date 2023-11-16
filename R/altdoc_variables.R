.substitute_altdoc_variables <- function(x, filename, path = ".") {
    x <- gsub("\\$ALTDOC_VERSION",utils::packageVersion("altdoc"), x)

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

    return(x)
}

