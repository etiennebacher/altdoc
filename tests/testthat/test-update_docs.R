test_that("docute: update_docs updates correctly the README", {
  create_local_package()
  use_docute()
  usethis::use_readme_md()
  readme1 <- readLines("README.md", warn = FALSE)
  readme2 <- readLines("docs/README.md", warn = FALSE)
  expect_false(identical(readme1, readme2))
  update_docs()
  readme2 <- readLines("docs/README.md", warn = FALSE)
  expect_true(identical(readme1, readme2))
})

test_that("docsify: update_docs updates correctly the README", {
  create_local_package()
  use_docsify()
  usethis::use_readme_md()
  readme1 <- readLines("README.md", warn = FALSE)
  readme2 <- readLines("docs/README.md", warn = FALSE)
  expect_false(identical(readme1, readme2))
  update_docs()
  readme2 <- readLines("docs/README.md", warn = FALSE)
  expect_true(identical(readme1, readme2))
})

test_that("mkdocs: update_docs updates correctly the README", {
  skip_mkdocs()
  create_local_package()
  use_mkdocs()
  usethis::use_readme_md()
  readme1 <- readLines("README.md", warn = FALSE)
  readme2 <- readLines("docs/docs/README.md", warn = FALSE)
  expect_false(identical(readme1, readme2))
  update_docs()
  readme2 <- readLines("docs/docs/README.md", warn = FALSE)
  expect_true(identical(readme1, readme2))
})


test_that("docute: update_docs updates correctly the NEWS", {
  create_local_package()
  usethis::use_news_md()
  writeLines("Hello", con = "NEWS.md")
  use_docute()
  writeLines("Hello again", con = "NEWS.md")
  news1 <- readLines("NEWS.md", warn = FALSE)
  news2 <- readLines("docs/NEWS.md", warn = FALSE)
  expect_false(identical(news1, news2))

  update_docs()
  news2 <- readLines("docs/NEWS.md", warn = FALSE)
  expect_true(identical(news1, news2))
})

test_that("docsify: update_docs updates correctly the NEWS", {
  create_local_package()
  usethis::use_news_md()
  writeLines("Hello", con = "NEWS.md")
  use_docsify()
  writeLines("Hello again", con = "NEWS.md")
  news1 <- readLines("NEWS.md", warn = FALSE)
  news2 <- readLines("docs/NEWS.md", warn = FALSE)
  expect_false(identical(news1, news2))

  update_docs()
  news2 <- readLines("docs/NEWS.md", warn = FALSE)
  expect_true(identical(news1, news2))
})

test_that("mkdocs: update_docs updates correctly the NEWS", {
  skip_mkdocs()
  create_local_package()
  usethis::use_news_md()
  writeLines("Hello", con = "NEWS.md")
  use_mkdocs()
  writeLines("Hello again", con = "NEWS.md")
  news1 <- readLines("NEWS.md", warn = FALSE)
  news2 <- readLines("docs/docs/NEWS.md", warn = FALSE)
  expect_false(identical(news1, news2))

  update_docs()
  news2 <- readLines("docs/docs/NEWS.md", warn = FALSE)
  expect_true(identical(news1, news2))
})

test_that("docsify: update_docs shows message when NEWS didn't exist", {
  create_local_package()
  use_docsify()
  usethis::use_news_md()
  expect_message(update_docs(),
                 regexp = "'NEWS / Changelog' was imported for the first time.")
})

test_that("docute: update_docs shows message when NEWS didn't exist", {
  create_local_package()
  use_docute()
  usethis::use_news_md()
  expect_message(update_docs(),
                 regexp = "'NEWS / Changelog' was imported for the first time.")
})

test_that("mkdocs: update_docs shows message when NEWS didn't exist", {
  skip_mkdocs()
  create_local_package()
  use_mkdocs()
  usethis::use_news_md()
  expect_message(update_docs(),
                 regexp = "'NEWS / Changelog' was imported for the first time.")
})

test_that("docsify: update_docs shows message when NEWS doesn't exist", {
  create_local_package()
  use_docsify()
  expect_message(update_docs(),
                 regexp = "No 'NEWS / Changelog' to include.")
})

test_that("docute: update_docs shows message when NEWS doesn't exist", {
  create_local_package()
  use_docute()
  expect_message(update_docs(),
                 regexp = "No 'NEWS / Changelog' to include.")
})

test_that("mkdocs: update_docs shows message when NEWS doesn't exist", {
  skip_mkdocs()
  create_local_package()
  use_mkdocs()
  expect_message(update_docs(),
                 regexp = "No 'NEWS / Changelog' to include.")
})

test_that("docute: update_docs also transform new/modified vignettes", {
  # setup
  first_rmd <- readLines(
    testthat::test_path("examples/examples-vignettes", "basic.Rmd"),
    warn = FALSE
  )
  second_rmd <- readLines(
    testthat::test_path("examples/examples-vignettes", "several-outputs.Rmd"),
    warn = FALSE
  )
  create_local_package()
  fs::dir_create("vignettes")
  writeLines(first_rmd, "vignettes/basic.Rmd")
  use_docute(convert_vignettes = TRUE)
  writeLines(second_rmd, "vignettes/several-outputs.Rmd")

  expect_false(fs::file_exists("docs/articles/several-outputs.md"))
  update_docs()
  expect_true(fs::file_exists("docs/articles/several-outputs.md"))
})

test_that("docsify: update_docs also transform new/modified vignettes", {
  # setup
  first_rmd <- readLines(
    testthat::test_path("examples/examples-vignettes", "basic.Rmd"),
    warn = FALSE
  )
  second_rmd <- readLines(
    testthat::test_path("examples/examples-vignettes", "several-outputs.Rmd"),
    warn = FALSE
  )
  create_local_package()
  fs::dir_create("vignettes")
  writeLines(first_rmd, "vignettes/basic.Rmd")
  use_docsify(convert_vignettes = TRUE)
  writeLines(second_rmd, "vignettes/several-outputs.Rmd")

  expect_false(fs::file_exists("docs/articles/several-outputs.md"))
  update_docs()
  expect_true(fs::file_exists("docs/articles/several-outputs.md"))
})

test_that("mkdocs: update_docs also transform new/modified vignettes", {
  skip_mkdocs()
  # setup
  first_rmd <- readLines(
    testthat::test_path("examples/examples-vignettes", "basic.Rmd"),
    warn = FALSE
  )
  second_rmd <- readLines(
    testthat::test_path("examples/examples-vignettes", "several-outputs.Rmd"),
    warn = FALSE
  )
  create_local_package()
  fs::dir_create("vignettes")
  writeLines(first_rmd, "vignettes/basic.Rmd")
  use_mkdocs(convert_vignettes = TRUE)
  writeLines(second_rmd, "vignettes/several-outputs.Rmd")

  expect_false(fs::file_exists("docs/docs/articles/several-outputs.md"))
  update_docs()
  expect_true(fs::file_exists("docs/docs/articles/several-outputs.md"))
})

