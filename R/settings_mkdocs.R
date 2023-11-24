.finalize_mkdocs <- function(settings, path, ...) {
    # fix links
    settings <- gsub(": \\/", ": ", settings)
    settings <- gsub("\\.md$", "", settings)

    # Fix vignette relative links before calling `mkdocs`
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
        txt <- gsub(
            sprintf('src=\\"%s.markdown_strict_files', v),
            sprintf('src=\\"\\.\\.\\/%s.markdown_strict_files', v),
            txt)
        writeLines(txt, fn)
    }

    # Fix man page relative links
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

    # write mutable sidebar
    fn <- fs::path_join(c(path, "mkdocs.yml"))
    writeLines(settings, fn)

    # plugins must be a list otherwise this command breaks: mkdocs build -q
    yml <- yaml::read_yaml(fn)
    if ("plugins" %in% names(yml)) {
        yml[["plugins"]] <- as.list(yml[["plugins"]])
    }

    # clean and rebuild index
    if (fs::file_exists(fn)) {
        fs::file_delete(fn)
    }
    yaml::write_yaml(yml, fn)

    fn <- fs::path_join(c(path, "index.html"))
    if (fs::file_exists(fn)) {
        fs::file_delete(fn)
    }


    # render mkdocs
    if (.is_windows()) {
        ### TODO: (cd <path> && python3 -m mkdocs build -q) should automatically go back to the previous directory
        ### https://stackoverflow.com/questions/10382141/temporarily-change-current-working-directory-in-bash-to-run-a-command
        goback <- fs::path_abs(getwd())
        cmd <- paste("cd", fs::path_abs(path), "&& python3 -m mkdocs build -q")
        shell(cmd)
        shell(paste("cd", goback))
    } else {
        goback <- getwd()
        cmd <- paste(fs::path_abs(path), "&& python3 -m mkdocs build -q")
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


.sidebar_vignettes_mkdocs <- function(sidebar, path) {
    dn <- fs::path_join(c(.doc_path(path), "vignettes"))
    fn_vignettes <- list.files(dn, pattern = "\\.md$", full.names = TRUE)

    # before gsub on paths
    titles <- sapply(fn_vignettes, .get_vignettes_titles)
    fn_vignettes <- sapply(fn_vignettes, function(x) {
        fs::path_join(c("vignettes", basename(x)))
    })

    .assert_dependency("yaml", install = TRUE)
    if (length(fn_vignettes) > 0) {
        yml <- paste(sidebar, collapse = "\n")
        yml <- yaml::yaml.load(yml)
        for (i in seq_along(yml$nav)) {
            if (isTRUE(yml$nav[[i]][[1]] == "$ALTDOC_VIGNETTE_BLOCK")) {
                section_name <- names(yml$nav[[i]])
                title_link <- as.list(stats::setNames(fn_vignettes, titles))
                yml$nav[[i]] <- stats::setNames(list(title_link), section_name)
            }
        }
        tmp <- tempfile()
        yaml::write_yaml(yml, file = tmp)
        sidebar <- .readlines(tmp)
    } else {
        sidebar <- sidebar[!grepl("\\$ALTDOC_VIGNETTE_BLOCK", sidebar)]
    }

    return(sidebar)
}


.sidebar_man_mkdocs <- function(sidebar, path) {
    .assert_dependency("yaml", install = TRUE)

    fn_man <- fs::path_join(c(.doc_path(path), "reference.md"))
    dn_man <- fs::path_join(c(.doc_path(path), "man"))

    if (fs::dir_exists(dn_man) && length(fs::dir_ls(dn_man)) > 0) {
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
    return(sidebar)
}
