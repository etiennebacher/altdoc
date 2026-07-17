test_that(".stage_external_includes() stages includes that escape the tree", {
    root <- withr::local_tempdir()

    # source tree: a shared macros file outside vignettes/, referenced via `..`
    fs::dir_create(fs::path_join(c(root, "macros")))
    writeLines("MACROS", fs::path_join(c(root, "macros", "macros.qmd")))

    # `_quarto/` tree as altdoc assembles it before rendering
    vig <- fs::path_join(c(root, "_quarto", "vignettes"))
    fs::dir_create(fs::path_join(c(vig, "articles")))
    writeLines(
        c(
            "{{< include ../macros/macros.qmd >}}",
            "{{< include articles/_local.qmd >}}"
        ),
        fs::path_join(c(vig, "methodology.qmd"))
    )
    # an in-tree include, already staged with its directory
    writeLines("LOCAL", fs::path_join(c(vig, "articles", "_local.qmd")))

    .stage_external_includes(
        src_dir = root,
        quarto_dir = fs::path_join(c(root, "_quarto"))
    )

    # the escaping include is copied to the path Quarto will resolve it to
    staged <- fs::path_join(c(root, "_quarto", "macros", "macros.qmd"))
    expect_true(fs::file_exists(staged))
    expect_identical(.readlines(staged), "MACROS")

    # the in-tree include is left where it already was, not re-staged elsewhere
    expect_false(
        fs::file_exists(fs::path_join(c(root, "_quarto", "articles", "_local.qmd")))
    )
})

test_that(".stage_external_includes() follows nested includes recursively", {
    root <- withr::local_tempdir()

    fs::dir_create(fs::path_join(c(root, "macros")))
    # macros.qmd itself pulls in a sibling via an escaping include
    writeLines(
        "{{< include ../shared/defs.qmd >}}",
        fs::path_join(c(root, "macros", "macros.qmd"))
    )
    fs::dir_create(fs::path_join(c(root, "shared")))
    writeLines("DEFS", fs::path_join(c(root, "shared", "defs.qmd")))

    vig <- fs::path_join(c(root, "_quarto", "vignettes"))
    fs::dir_create(vig)
    writeLines(
        "{{< include ../macros/macros.qmd >}}",
        fs::path_join(c(vig, "methodology.qmd"))
    )

    .stage_external_includes(
        src_dir = root,
        quarto_dir = fs::path_join(c(root, "_quarto"))
    )

    expect_true(
        fs::file_exists(fs::path_join(c(root, "_quarto", "macros", "macros.qmd")))
    )
    expect_true(
        fs::file_exists(fs::path_join(c(root, "_quarto", "shared", "defs.qmd")))
    )
})
