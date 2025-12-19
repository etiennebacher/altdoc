test_that("docute: main files are correct", {
    skip_on_cran()
    skip_if(.is_windows() && .on_ci(), "Windows on CI")
    skip_if(!.quarto_is_installed())

    ### setup: create a temp package using the structure of testpkg.altdoc
    path_to_example_pkg <- fs::path_abs(test_path("examples/testpkg.altdoc"))
    create_local_project()
    fs::dir_delete("R")
    fs::dir_copy(path_to_example_pkg, ".")
    all_files <- list.files("testpkg.altdoc", full.names = TRUE)
    for (i in all_files) {
        fs::file_move(i, ".")
    }
    fs::dir_delete("testpkg.altdoc")

    ### generate docs
    install.packages(".", repos = NULL, type = "source")
    setup_docs("docute")
    render_docs(verbose = .on_ci())

    ### test
    expect_snapshot_file("docs/README.md", variant = "docute")
    expect_snapshot_file("docs/docute.html", variant = "docute")
    expect_snapshot_file("docs/NEWS.md", variant = "docute")
    expect_snapshot_file("docs/man/hello_base.md", variant = "docute")
    expect_snapshot_file("docs/man/hello_r6.md", variant = "docute")
    expect_snapshot_file("docs/man/examplesIf_true.md", variant = "docute")
    expect_snapshot_file("docs/man/examplesIf_false.md", variant = "docute")
    expect_snapshot_file("docs/vignettes/test.md", variant = "docute")
})

test_that("docsify: main files are correct", {
    skip_on_cran()
    skip_if(.is_windows() && .on_ci(), "Windows on CI")
    skip_if(!.quarto_is_installed())

    ### setup: create a temp package using the structure of testpkg.altdoc
    path_to_example_pkg <- fs::path_abs(test_path("examples/testpkg.altdoc"))
    create_local_project()
    fs::dir_delete("R")
    fs::dir_copy(path_to_example_pkg, ".")
    all_files <- list.files("testpkg.altdoc", full.names = TRUE)
    for (i in all_files) {
        fs::file_move(i, ".")
    }
    fs::dir_delete("testpkg.altdoc")

    ### generate docs
    install.packages(".", repos = NULL, type = "source")
    setup_docs("docsify")
    render_docs(verbose = .on_ci())

    ### test
    expect_snapshot_file("docs/README.md", variant = "docsify")
    expect_snapshot_file("docs/_sidebar.md", variant = "docsify")
    expect_snapshot_file("docs/NEWS.md", variant = "docsify")
    expect_snapshot_file("docs/man/hello_base.md", variant = "docsify")
    expect_snapshot_file("docs/man/hello_r6.md", variant = "docsify")
    expect_snapshot_file("docs/man/examplesIf_true.md", variant = "docsify")
    expect_snapshot_file("docs/man/examplesIf_false.md", variant = "docsify")
    expect_snapshot_file("docs/vignettes/test.md", variant = "docsify")
    # This changes imperceptedly between windows and Linux/macOS, but the old
    # and new snapshots are LF so I don't really know why.
    skip_if(.is_windows())
    expect_snapshot_file("docs/index.html", variant = "docsify")
})

test_that("mkdocs: main files are correct", {
    skip_on_cran()
    skip_if_offline() # we download mkdocs every time
    skip_if(.is_windows() && .on_ci(), "Windows on CI")
    skip_if(!.quarto_is_installed())

    ### setup: create a temp package using the structure of testpkg.altdoc
    path_to_example_pkg <- fs::path_abs(test_path("examples/testpkg.altdoc"))
    create_local_project()
    fs::dir_delete("R")
    fs::dir_copy(path_to_example_pkg, ".")
    all_files <- list.files("testpkg.altdoc", full.names = TRUE)
    for (i in all_files) {
        fs::file_move(i, ".")
    }
    fs::dir_delete("testpkg.altdoc")

    ### special mkdocs stuff
    if (.is_windows()) {
        shell("python3 -m venv .venv_altdoc")
        shell(
            ".venv_altdoc\\Scripts\\activate.bat && python3 -m pip install mkdocs --quiet"
        )
    } else {
        system2("python3", "-m venv .venv_altdoc")
        system2(
            "bash",
            "-c 'source .venv_altdoc/bin/activate && python3 -m pip install mkdocs --quiet'",
            stdout = FALSE
        )
    }

    ### generate docs
    install.packages(".", repos = NULL, type = "source")
    setup_docs("mkdocs")
    render_docs(verbose = .on_ci())

    ### test
    # no good way to test the site structure ("docs/mkdocs.yml" only shows
    # the old yaml, not the one with replaced variables)
    expect_snapshot_file("docs/NEWS.md", variant = "mkdocs")
    expect_snapshot_file("docs/man/hello_base.md", variant = "mkdocs")
    expect_snapshot_file("docs/man/hello_r6.md", variant = "mkdocs")
    expect_snapshot_file("docs/vignettes/test.md", variant = "mkdocs")
})

test_that("quarto: no error for basic workflow", {
    skip_on_cran()
    skip_if(.is_windows() && .on_ci(), "Windows on CI")
    skip_if(!.quarto_is_installed())

    ### setup: create a temp package using the structure of testpkg.altdoc
    path_to_example_pkg <- fs::path_abs(test_path("examples/testpkg.altdoc"))
    create_local_project()
    fs::dir_delete("R")
    fs::dir_copy(path_to_example_pkg, ".")
    all_files <- list.files("testpkg.altdoc", full.names = TRUE)
    for (i in all_files) {
        fs::file_move(i, ".")
    }
    fs::dir_delete("testpkg.altdoc")

    ### generate docs
    install.packages(".", repos = NULL, type = "source")
    setup_docs("quarto_website")
    expect_no_error(render_docs(verbose = .on_ci()))

    ### Quarto output changes depending on the version, I don't have a solution for
    ### now.

    ### test
    # expect_snapshot_file("docs/index.html")
    # expect_snapshot_file("docs/NEWS.html")
    # expect_snapshot_file("docs/man/hello_base.html")
    # expect_snapshot_file("docs/man/hello_r6.html")
    # expect_snapshot_file("docs/vignettes/test.html")
})

# https://github.com/etiennebacher/altdoc/issues/307
test_that("quarto: no error for basic workflow, no Github URL", {
    skip_on_cran()
    skip_if(.is_windows() && .on_ci(), "Windows on CI")
    skip_if(!.quarto_is_installed())

    ### setup: create a temp package using the structure of testpkg.altdoc.noURL
    path_to_example_pkg <- fs::path_abs(
        test_path("examples/testpkg.altdoc.noURL")
    )
    create_local_project()
    fs::dir_delete("R")
    fs::dir_copy(path_to_example_pkg, ".")
    all_files <- list.files("testpkg.altdoc.noURL", full.names = TRUE)
    for (i in all_files) {
        fs::file_move(i, ".")
    }
    fs::dir_delete("testpkg.altdoc.noURL")

    install.packages(".", repos = NULL, type = "source")
    setup_docs("quarto_website")
    expect_no_error(render_docs(verbose = .on_ci()))
})

# https://github.com/etiennebacher/altdoc/issues/318
test_that("quarto: no error for basic workflow, non-GitHub URL", {
    skip_on_cran()
    skip_if(.is_windows() && .on_ci(), "Windows on CI")
    skip_if(!.quarto_is_installed())

    ### setup: create a temp package using the structure of
    ### testpkg.altdoc.nonGithubURL
    path_to_example_pkg <- fs::path_abs(
        test_path("examples/testpkg.altdoc.nonGithubURL")
    )
    create_local_project()
    fs::dir_delete("R")
    fs::dir_copy(path_to_example_pkg, ".")
    all_files <- list.files("testpkg.altdoc.nonGithubURL", full.names = TRUE)
    for (i in all_files) {
        fs::file_move(i, ".")
    }
    fs::dir_delete("testpkg.altdoc.nonGithubURL")

    install.packages(".", repos = NULL, type = "source")
    setup_docs("quarto_website")
    expect_no_error(render_docs(verbose = .on_ci()))
})

# https://github.com/etiennebacher/altdoc/issues/323
test_that("docsify: footer is still present even if URL is absent", {
    skip_on_cran()
    skip_if(.is_windows() && .on_ci(), "Windows on CI")
    skip_if(!.quarto_is_installed())

    create_local_package()

    setup_docs("docsify")
    render_docs()
    html <- .readlines("docs/index.html")
    expect_true(any(grepl("Documentation made with", html, fixed = TRUE)))
})

for (tool in c("docute", "docsify", "quarto_website")) {
    test_that("no error with different types of README", {
        skip_on_cran()
        skip_if(.is_windows() && .on_ci(), "Windows on CI")
        skip_if(!.quarto_is_installed())

        create_local_package()

        # README.md
        cat("hello there", file = "README.md")
        setup_docs(tool)
        expect_no_error(render_docs(verbose = .on_ci()))
        fs::dir_delete("docs")

        # README.Rmd
        cat("hello there", file = "README.Rmd")
        expect_no_error(render_docs(verbose = .on_ci()))
        fs::dir_delete("docs")
        fs::file_delete("README.Rmd")

        # README.qmd
        cat("hello there", file = "README.qmd")
        expect_no_error(render_docs(verbose = .on_ci()))
    })
}

test_that("quarto: autolink", {
    skip_on_cran()
    skip_if(.is_windows() && .on_ci(), "Windows on CI")
    skip_if(!.quarto_is_installed())

    ### setup: create a temp package using the structure of testpkg.altdoc
    path_to_example_pkg <- fs::path_abs(test_path("examples/testpkg.altdoc"))
    create_local_project()
    fs::dir_delete("R")
    fs::dir_copy(path_to_example_pkg, ".")
    all_files <- list.files("testpkg.altdoc", full.names = TRUE)
    for (i in all_files) {
        fs::file_move(i, ".")
    }
    fs::dir_delete("testpkg.altdoc")

    ### generate docs
    install.packages(".", repos = NULL, type = "source")
    setup_docs("quarto_website")
    expect_no_error(render_docs(verbose = .on_ci()))

    tmp <- .readlines("docs/vignettes/test.html")
    expect_true(
        any(grepl("https://rdrr.io/r/base/library.html", tmp, fixed = TRUE))
    )
})

test_that("files in man/figures are copied to docs/help/figures", {
    skip_if(!.quarto_is_installed())
    path_to_example_pkg <- fs::path_abs(test_path("examples/testpkg.lifecycle"))
    create_local_project()
    fs::dir_delete("R")
    fs::dir_copy(path_to_example_pkg, ".")
    all_files <- list.files("testpkg.lifecycle", full.names = TRUE)
    for (i in all_files) {
        fs::file_move(i, ".")
    }
    fs::dir_delete("testpkg.lifecycle")

    ### generate docs
    install.packages(".", repos = NULL, type = "source")
    setup_docs("docute")
    expect_no_error(render_docs(verbose = .on_ci()))
    expect_true(fs::file_exists("docs/help/figures/lifecycle-experimental.svg"))
    md <- .readlines("docs/man/foo.md")
    expect_true(any(grepl(
        "../help/figures/lifecycle-experimental.svg",
        md,
        fixed = TRUE
    )))

    ### re-rendering works
    expect_no_error(render_docs(verbose = .on_ci()))
})

test_that("mkdocs: index.html is reset at every render_docs(), #336", {
    skip_on_cran()
    skip_if_offline() # we download mkdocs every time
    skip_if(.is_windows())
    skip_if(!.quarto_is_installed())

    ### setup: create a temp package using the structure of testpkg.altdoc
    create_local_package()
    fs::dir_delete("R")

    system2("python3", "-m venv .venv_altdoc")
    system2(
        "bash",
        "-c 'source .venv_altdoc/bin/activate && python3 -m pip install mkdocs mkdocs-material --quiet'",
        stdout = FALSE
    )

    ### generate docs
    install.packages(".", repos = NULL, type = "source")
    setup_docs("mkdocs")

    ### Custom overrides partial
    fs::dir_create("altdoc/overrides/partials")
    cat("HELLO THERE", file = "altdoc/overrides/partials/copyright.html")
    cat(
        "site_name: foo
theme:
  name: material
  custom_dir: altdoc/overrides",
        file = "altdoc/mkdocs.yml"
    )

    render_docs(verbose = .on_ci())
    expect_true(any(grepl(
        "HELLO THERE",
        .readlines("docs/index.html"),
        fixed = TRUE
    )))

    ### Ensure that the overrides/partial is updated
    cat("HELLO AGAIN", file = "altdoc/overrides/partials/copyright.html")
    render_docs(verbose = .on_ci())
    expect_false(any(grepl(
        "HELLO THERE",
        .readlines("docs/index.html"),
        fixed = TRUE
    )))
    expect_true(any(grepl(
        "HELLO AGAIN",
        .readlines("docs/index.html"),
        fixed = TRUE
    )))
})

test_that(".add_pkgdown() works", {
    skip_on_cran()
    skip_if(.is_windows() && .on_ci(), "Windows on CI")
    skip_if(!.quarto_is_installed())

    ### setup: create a temp package using the structure of testpkg.altdoc
    path_to_example_pkg <- fs::path_abs(test_path("examples/testpkg.altdoc"))
    create_local_project()
    fs::dir_delete("R")
    fs::dir_copy(path_to_example_pkg, ".")
    all_files <- list.files("testpkg.altdoc", full.names = TRUE)
    for (i in all_files) {
        fs::file_move(i, ".")
    }
    fs::dir_delete("testpkg.altdoc")
    desc::desc_add_urls("https://mywebsite.com")

    timestamp_regex <- "\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\+\\d{4}"

    ### generate docs
    install.packages(".", repos = NULL, type = "source")
    setup_docs("docute")
    expect_snapshot(
        cat(.readlines("altdoc/pkgdown.yml"), sep = "\n"),
        transform = function(x) {
            first_timestamp <<- regmatches(x, gregexpr(timestamp_regex, x)) |>
                unlist()
            x <- gsub("\\d+\\.\\d+\\.\\d+(\\.\\d+|)", "0.0.0", x)
            x <- gsub(
                timestamp_regex,
                "2020-01-01T00:00:00+0000",
                x
            )
            x
        }
    )

    ### There are not many fields that are updated because if they were created
    ### by the user then we don't want to overwrite them.
    ### render_docs() should update pkgdown.yml with a new timestamp, so we can
    ### check that it is different than the initial one.
    Sys.sleep(1)
    render_docs()
    content <- .readlines("altdoc/pkgdown.yml")
    second_timestamp <- regmatches(
        content,
        gregexpr(timestamp_regex, content)
    ) |>
        unlist()

    expect_true(first_timestamp != second_timestamp)

    ### render_docs() doesn't remove pre-existing fields in pkgdown.yml
    cat(
        "altdoc: 0.0.0
pandoc: 0.0.0
pkgdown: 0.0.0
last_built: 2020-01-01T00:00:00+0000
articles:
  polars: polars.html
  install: install.html
urls:
  reference: https://anotherwebsite.com/man
  article: https://anotherwebsite.com/vignettes\n",
        file = "altdoc/pkgdown.yml"
    )
    render_docs()
    expect_snapshot(
        cat(.readlines("altdoc/pkgdown.yml"), sep = "\n"),
        transform = function(x) {
            x <- gsub("\\d+\\.\\d+\\.\\d+(\\.\\d+|)", "0.0.0", x)
            x <- gsub(
                "\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\+\\d{4}",
                "2020-01-01T00:00:00+0000",
                x
            )
            x
        }
    )
})

# Test failures ------------------------------

test_that("render_docs errors if vignettes fail", {
    skip_if(!.quarto_is_installed())
    create_local_package()
    fs::dir_create("vignettes")
    cat("# Get Started\n```{r}\n1 +\n```\n", file = "vignettes/foo.Rmd")
    setup_docs("docute", path = getwd())
    expect_error(
        render_docs(path = getwd()),
        "some failures when rendering vignettes"
    )
})

test_that("render_docs errors if man fail", {
    skip_if(!.quarto_is_installed())
    create_local_package()
    fs::dir_create("man")
    cat(
        "\\name{hi}\n\\title{hi}\n\\usage{\nhi()\n}\n\\examples{\n1 +\n}\n",
        file = "man/foo.Rd"
    )
    setup_docs("docute", path = getwd())
    expect_error(
        render_docs(path = getwd()),
        "some failures when rendering man pages"
    )
})
