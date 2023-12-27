# README --------------------------------------------------------

for (tool in c("docute", "docsify")) {
  test_that(sprintf("render_docs updates correctly the README: %s", tool), {
    skip_if(tool == "mkdocs" && !.venv_exists())
    create_local_package()
    setup_docs(tool = tool, path = getwd())
    usethis::use_readme_md(open = FALSE)
    render_docs(path = getwd())
    readme1 <- .readlines("README.md")
    readme2 <- .readlines("docs/README.md")
    expect_true(identical(readme1, readme2))
  })
}




# NEWS --------------------------------------------------------

for (tool in c("docute", "docsify")) {
  test_that(sprintf("render_docs updates correctly the NEWS: %s", tool), {
    skip_if(tool == "mkdocs" && !.venv_exists())
    create_local_package()
    # https://github.com/cynkra/fledge/issues/683
    withr::with_options(
      list(repos = c("CRAN" = "https://cloud.r-project.org")),
      {
        usethis::use_news_md()
    })
    setup_docs(tool = tool, path = getwd(), overwrite = TRUE)
    writeLines("Hello", con = "NEWS.md")
    render_docs(path = getwd())
    writeLines("Hello again", con = "NEWS.md")
    news1 <- .readlines("NEWS.md")
    news2 <- .readlines("docs/NEWS.md")
    expect_false(identical(news1, news2))
    render_docs(path = getwd())
    news2 <- .readlines("docs/NEWS.md")
    expect_true(identical(news1, news2))
  })
}




# CODE OF CONDUCT --------------------------------------------------------

for (tool in c("docute", "docsify")) {
  test_that(sprintf("docute: render_docs updates correctly the CoC, %s", tool), {
    skip_if(tool == "mkdocs" && !.venv_exists())
    create_local_package()
    usethis::use_code_of_conduct("etienne.bacher@protonmail.com")
    writeLines("Hello", con = "CODE_OF_CONDUCT.md")
    setup_docs(tool = tool, path = getwd())
    render_docs(path = getwd())
    writeLines("Hello again", con = "CODE_OF_CONDUCT.md")
    news1 <- .readlines("CODE_OF_CONDUCT.md")
    news2 <- .readlines("docs/CODE_OF_CONDUCT.md")
    expect_false(identical(news1, news2))
    render_docs(path = getwd())
    news2 <- .readlines("docs/CODE_OF_CONDUCT.md")
    expect_true(identical(news1, news2))
  })
}




# LICENSE --------------------------------------------------------

for (tool in c("docute", "docsify")) {
  test_that(sprintf("render_docs updates correctly the License: %s", tool), {
    skip_if(tool == "mkdocs" && !.venv_exists())
    create_local_package()
    usethis::use_mit_license("etienne.bacher@protonmail.com")
    writeLines("Hello", con = "LICENSE.md")
    setup_docs(tool = tool, path = getwd())
    render_docs(path = getwd())
    writeLines("Hello again", con = "LICENSE.md")
    news1 <- .readlines("LICENSE.md")
    news2 <- .readlines("docs/LICENSE.md")
    expect_false(identical(news1, news2))
    render_docs(path = getwd())
    news2 <- .readlines("docs/LICENSE.md")
    expect_true(identical(news1, news2))
  })
}





# VIGNETTES --------------------------------------------------------

for (tool in c("docute", "docsify")) {
  test_that(sprintf("render_docs also transform new/modified vignettes if specified: %s", tool), {
    skip_on_ci()
    skip_if(tool == "mkdocs" && !.venv_exists())
    # setup
    first_rmd <- .readlines(
      testthat::test_path("examples/examples-vignettes", "basic.Rmd")
    )
    second_rmd <- .readlines(
      testthat::test_path("examples/examples-vignettes", "several-outputs.Rmd")
    )
    create_local_package()
    fs::dir_create("vignettes")
    writeLines(first_rmd, "vignettes/basic.Rmd")
    setup_docs(tool = tool, path = getwd())
    render_docs(path = getwd())
    writeLines(second_rmd, "vignettes/several-outputs.Rmd")
    expect_false(fs::file_exists("docs/vignettes/several-outputs.md"))
    # mkdocs does not accept duplicate vignette names
    if (tool != "mkdocs") {
      render_docs(path = getwd())
      expect_true(fs::file_exists("docs/vignettes/several-outputs.md"))
    }
  })
}
