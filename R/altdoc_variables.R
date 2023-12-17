.substitute_altdoc_variables <- function(x, filename, tool = "docsify") {
    x <- gsub("\\$ALTDOC_VERSION", utils::packageVersion("altdoc"), x)

    files <- c("NEWS.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "CONTRIBUTING.md", "LICENSE.md", "LICENCE.md", "CITATION.md")
    for (fn in files) {
        regex <- sprintf("\\$ALTDOC_%s", fs::path_ext_remove(basename(fn)))
        if (fs::file_exists(fn) || fs::file_exists(fs::path_join(c("_quarto/docs", fn)))) {
            if (tool == "docute") {
                new <- paste0("/", fn)
            } else {
                new <- fn
            }
            x <- gsub(regex, new, x)
        } else {
            x <- x[!grepl(regex, x)]
        }
    }

    # DESCRIPTION file
    if (fs::file_exists("DESCRIPTION")) {
        gh_url <- .gh_url(getwd())
        if (length(gh_url) > 0) {
            x <- gsub("\\$ALTDOC_PACKAGE_URL_GITHUB", gh_url, x)
        } else {
            x <- x[!grepl("\\$ALTDOC_PACKAGE_URL_GITHUB", x)]
        }

        all_urls <- tryCatch(desc::desc_get_urls(getwd()), error = function(e) NULL)
        website_url <- Filter(function(x) !grepl("github.com", x), all_urls)

        if (length(website_url) > 0) {
            x <- gsub("\\$ALTDOC_PACKAGE_URL", website_url[1], x)
        } else {
            x <- x[!grepl("\\$ALTDOC_PACKAGE_URL", x)]
        }

        x <- gsub("\\$ALTDOC_PACKAGE_NAME", desc::desc_get("Package", getwd()), x)
        x <- gsub("\\$ALTDOC_PACKAGE_VERSION", desc::desc_get("Version", getwd()), x)


    } else {
        x <- gsub("\\$ALTDOC_PACKAGE_NAME", "", x)
        x <- gsub("\\$ALTDOC_PACKAGE_VERSION", "", x)
        x <- x[grepl("\\$ALTDOC_PACKAGE_URL_GITHUB")] # before the other one
        x <- gsub("\\$ALTDOC_PACKAGE_URL", "", x)
    }

    # some commands expand the full path
    x <- gsub(.doc_path(getwd()), "", x, fixed = TRUE)

    return(x)
}
