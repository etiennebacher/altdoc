.import_settings_mkdocs <- function(path) {

    # TODO: opportunity for DRY in the vignette and man blocks

    .assert_dependency("yaml")

    # Read settings sidebar
    fn <- fs::path_join(c(path, "altdoc", "mkdocs.yml"))
    sidebar <- readLines(fn, warn = FALSE)

    # Single files
    if (fs::file_exists(fs::path_join(c(.doc_path(path), "NEWS.md")))) {
        sidebar <- gsub("\\$ALTDOC_NEWS", "NEWS.md", sidebar)
    } else {
        sidebar <- sidebar[!grepl(".*\\$ALTDOC_NEWS", sidebar)]
    }

    if (fs::file_exists(fs::path_join(c(.doc_path(path), "LICENSE.md")))) {
        sidebar <- gsub("\\$ALTDOC_LICENSE", "LICENSE.md", sidebar)
    } else {
        sidebar <- sidebar[!grepl(".*\\$ALTDOC_LICENSE", sidebar)]
    }

    if (fs::file_exists(fs::path_join(c(.doc_path(path), "CODE_OF_CONDUCT.md")))) {
        sidebar <- gsub("\\$ALTDOC_CODE_OF_CONDUCT", "CODE_OF_CONDUCT.md", sidebar)
    } else {
        sidebar <- sidebar[!grepl(".*\\$ALTDOC_CODE_OF_CONDUCT", sidebar)]
    }


    ############### Vignettes
    # TODO: get clean titles. .get_vignettes_titles does not work as I expected
    dn1 <- fs::path_join(c(.doc_path(path), "vignettes"))
    dn2 <- fs::path_join(c(.doc_path(path), "articles"))
    fn_vignettes <- c(
        list.files(dn1, pattern = "\\.md$", full.names = TRUE),
        list.files(dn2, pattern = "\\.md$", full.names = TRUE)
    )
    # before gsub on paths
    titles <- sapply(fn_vignettes, .get_vignettes_titles)
    fn_vignettes <- sapply(fn_vignettes, function(x) 
        {
            fs::path_join(c("articles", basename(x)))
        }
    )

    if (length(fn_vignettes) > 0) {
        yml <- paste(sidebar, collapse = "\n")
        yml <- yaml::yaml.load(yml)
        for (i in seq_along(yml$nav)) {
            if (isTRUE(yml$nav[[i]][[1]] == "$ALTDOC_VIGNETTE_BLOCK")) {
                section_name <- names(yml$nav[[i]])
                title_link <- as.list(stats::setNames(fn_vignettes, titles))
                yml$nav[[i]] <-stats::setNames(list(title_link), section_name)
            }
        }
        tmp <- tempfile()
        yaml::write_yaml(yml, file = tmp)
        sidebar <- readLines(tmp)

    } else {
        sidebar <- sidebar[!grepl("\\$ALTDOC_VIGNETTE_BLOCK", sidebar)]
    }


    ########## Man pages
    fn_man <- fs::path_join(c(.doc_path(path), "reference.md"))
    dn_man <- fs::path_join(c(.doc_path(path), "man"))

    if (fs::dir_exists(dn_man)) {
        fn_man <- list.files(dn_man, pattern = "\\.md$", full.names = TRUE)
        fn_man <- sapply(fn_man, function(x) fs::path_join(c("man", basename(x))))
        titles <- fs::path_ext_remove(basename(fn_man))

        yml <- paste(sidebar, collapse = "\n")
        yml <- yaml::yaml.load(yml)
        for (i in seq_along(yml$nav)) {
            if (isTRUE(yml$nav[[i]][[1]] == "$ALTDOC_MAN_BLOCK")) {
                section_name <- names(yml$nav[[i]])
                title_link <- as.list(stats::setNames(fn_man, titles))
                yml$nav[[i]] <-stats::setNames(list(title_link), section_name)
            }
        }
        tmp <- tempfile()
        yaml::write_yaml(yml, file = tmp)
        sidebar <- readLines(tmp)

    } else {
        sidebar <- sidebar[!grepl("\\$ALTDOC_MAN_BLOCK", sidebar)]
    }

    sidebar <- .substitute_altdoc_variables(sidebar, path = path)

    # write mutable sidebar
    fn <- fs::path_join(c(path, "mkdocs.yml"))
    writeLines(sidebar, fn)


    # plugins must be a list otherwise this command breaks: mkdocs build -q
    yml <- yaml::read_yaml(fn)
    if ("plugins" %in% names(yml)) {
        yml[["plugins"]] <- as.list(yml[["plugins"]])
    }
    yaml::write_yaml(yml, fn)


    # render mkdocs
    if (.is_windows() & interactive()) {
        cmd <- paste(fs::path_abs(.doc_path(path)), "&& mkdocs build -q")
        shell("cd", cmd)
    } else {
        goback <- getwd()
        cmd <- paste(fs::path_abs(path), "&& mkdocs build -q")
        system2("cd", cmd)
        system2("cd", goback)
    }

    # move to docs/
    fs::file_move(fs::path_join(c(path, "mkdocs.yml")), .doc_path(path))
    tmp <- fs::path_join(c(path, "site/"))
    src <- fs::dir_ls(tmp, recurse = TRUE)
    tar <- sub("site\\/", "docs\\/", src)
    for (i in seq_along(src)) {
        fs::dir_create(fs::path_dir(tar[i]))  # Create the directory if it doesn't exist
        if (fs::is_file(src[i])) {
        fs::file_copy(src[i], tar[i], overwrite = TRUE)
        }
    }
    fs::dir_delete(fs::path_join(c(path, "site")))
}