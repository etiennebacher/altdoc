test_that("quarto: reference.yml groups/orders the man index and sidebar", {
    skip_on_cran()
    skip_if(.is_windows() && .on_ci(), "Windows on CI")
    skip_if(!.quarto_is_installed())

    path_to_example_pkg <- fs::path_abs(test_path("examples/testpkg.altdoc"))
    create_local_project()
    fs::dir_delete("R")
    fs::dir_copy(path_to_example_pkg, ".")
    all_files <- list.files("testpkg.altdoc", full.names = TRUE)
    for (i in all_files) {
        fs::file_move(i, ".")
    }
    fs::dir_delete("testpkg.altdoc")

    install.packages(".", repos = NULL, type = "source")
    setup_docs("quarto_website")

    writeLines(
        c(
            "- title: Greetings",
            "  contents:",
            "    - hello_base",
            "    - hello_r6",
            "- title: Conditional examples",
            "  contents:",
            "    - examplesIf_true",
            "    - examplesIf_false"
        ),
        "altdoc/reference.yml"
    )

    expect_no_error(render_docs(verbose = .on_ci()))

    ### the grouped index page was generated ...
    expect_true(fs::file_exists("docs/man/index.html"))
    index_html <- .readlines("docs/man/index.html")
    expect_true(any(grepl("Greetings", index_html, fixed = TRUE)))
    expect_true(any(grepl("Conditional examples", index_html, fixed = TRUE)))
    # groups appear in the order given in reference.yml
    expect_true(
        grep("Greetings", index_html, fixed = TRUE)[1] <
            grep("Conditional examples", index_html, fixed = TRUE)[1]
    )
    expect_true(any(grepl("hello_base", index_html, fixed = TRUE)))
    expect_true(any(grepl("Base function", index_html, fixed = TRUE)))

    ### ... and the sidebar reflects the same grouping
    man_html <- .readlines("docs/man/hello_base.html")
    expect_true(any(grepl("Greetings", man_html, fixed = TRUE)))
    expect_true(any(grepl("Conditional examples", man_html, fixed = TRUE)))
})

test_that("quarto: reference.yml errors on unknown function names", {
    skip_on_cran()
    skip_if(.is_windows() && .on_ci(), "Windows on CI")
    skip_if(!.quarto_is_installed())

    path_to_example_pkg <- fs::path_abs(test_path("examples/testpkg.altdoc"))
    create_local_project()
    fs::dir_delete("R")
    fs::dir_copy(path_to_example_pkg, ".")
    all_files <- list.files("testpkg.altdoc", full.names = TRUE)
    for (i in all_files) {
        fs::file_move(i, ".")
    }
    fs::dir_delete("testpkg.altdoc")

    install.packages(".", repos = NULL, type = "source")
    setup_docs("quarto_website")

    writeLines(
        c(
            "- title: Greetings",
            "  contents:",
            "    - not_a_real_function"
        ),
        "altdoc/reference.yml"
    )

    expect_error(render_docs(verbose = .on_ci()), "not_a_real_function")
})

test_that("quarto: reference.yml warns on undocumented topics", {
    skip_on_cran()
    skip_if(.is_windows() && .on_ci(), "Windows on CI")
    skip_if(!.quarto_is_installed())

    path_to_example_pkg <- fs::path_abs(test_path("examples/testpkg.altdoc"))
    create_local_project()
    fs::dir_delete("R")
    fs::dir_copy(path_to_example_pkg, ".")
    all_files <- list.files("testpkg.altdoc", full.names = TRUE)
    for (i in all_files) {
        fs::file_move(i, ".")
    }
    fs::dir_delete("testpkg.altdoc")

    install.packages(".", repos = NULL, type = "source")
    setup_docs("quarto_website")

    writeLines(
        c(
            "- title: Greetings",
            "  contents:",
            "    - hello_base"
        ),
        "altdoc/reference.yml"
    )

    expect_warning(render_docs(verbose = .on_ci()), "hello_r6")
})

test_that("quarto: no reference.yml keeps the current flat/alphabetical behavior", {
    skip_on_cran()
    skip_if(.is_windows() && .on_ci(), "Windows on CI")
    skip_if(!.quarto_is_installed())

    path_to_example_pkg <- fs::path_abs(test_path("examples/testpkg.altdoc"))
    create_local_project()
    fs::dir_delete("R")
    fs::dir_copy(path_to_example_pkg, ".")
    all_files <- list.files("testpkg.altdoc", full.names = TRUE)
    for (i in all_files) {
        fs::file_move(i, ".")
    }
    fs::dir_delete("testpkg.altdoc")

    install.packages(".", repos = NULL, type = "source")
    setup_docs("quarto_website")

    expect_no_error(render_docs(verbose = .on_ci()))
    expect_false(fs::file_exists("docs/man/index.html"))
})
