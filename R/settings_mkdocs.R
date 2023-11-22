.import_settings_mkdocs <- function(path) {

    # TODO: opportunity for DRY in the vignette and man blocks

    .assert_dependency("yaml", install = TRUE)

    # Read settings sidebar
    fn <- fs::path_join(c(path, "altdoc", "mkdocs.yml"))
    sidebar <- .readlines(fn)

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
    dn <- fs::path_join(c(.doc_path(path), "vignettes"))
    fn_vignettes <- list.files(dn, pattern = "\\.md$", full.names = TRUE)

    # before gsub on paths
    titles <- sapply(fn_vignettes, .get_vignettes_titles)
    fn_vignettes <- sapply(fn_vignettes, function(x) 
        {
            fs::path_join(c("vignettes", basename(x)))
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
        sidebar <- .readlines(tmp)

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
                yml$nav[[i]] <- stats::setNames(list(title_link), section_name)
            }
        }
        tmp <- tempfile()
        yaml::write_yaml(yml, file = tmp)
        sidebar <- .readlines(tmp)

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
    if (.is_windows()) {
        ### TODO: (cd <path> && mkdocs build -q) should automatically go back to the previous directory
        ### https://stackoverflow.com/questions/10382141/temporarily-change-current-working-directory-in-bash-to-run-a-command
        goback <- fs::path_abs(getwd())
        cmd <- paste("cd", fs::path_abs(path), "&& mkdocs build -q")
        shell(cmd)
        shell(paste("cd", goback))
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

    # Fix vignette relative links
    vignettes <- list.files(
        fs::path_join(c(.doc_path(path), "vignettes")),
        pattern = "\\.md")
    vignettes <- gsub("\\.md$", "", vignettes)
    for (v in vignettes) {
        fn <- fs::path_join(c(.doc_path(path), "vignettes", paste0(v, ".md")))
        txt <- .readlines(fn)
        txt <- gsub(
            paste0("![](", .doc_path(path), "/vignettes/"),
            "![](",
            txt,
            fixed = TRUE)
        writeLines(txt, fn)
    }

    # Fix vignette relative links
    man <- list.files(
        fs::path_join(c(.doc_path(path), "man")),
        pattern = "\\.md")
    man <- gsub("\\.md$", "", man)
    for (v in man) {
        fn <- fs::path_join(c(.doc_path(path), "man", paste0(v, ".md")))
        txt <- .readlines(fn)
        txt <- gsub(
            paste0("![](", .doc_path(path), "/man/"),
            "![](",
            txt,
            fixed = TRUE)
        writeLines(txt, fn)
    }
}