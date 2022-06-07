# README --------------------------------------------------------

test_that("docute: update_docs updates correctly the README", {
  create_local_package()
  use_docute(path = getwd())
  usethis::use_readme_md()
  readme1 <- readLines("README.md", warn = FALSE)
  readme2 <- readLines("docs/README.md", warn = FALSE)
  expect_false(identical(readme1, readme2))
  update_docs(path = getwd())
  readme2 <- readLines("docs/README.md", warn = FALSE)
  expect_true(identical(readme1, readme2))
})

test_that("docsify: update_docs updates correctly the README", {
  create_local_package()
  use_docsify(path = getwd())
  usethis::use_readme_md()
  readme1 <- readLines("README.md", warn = FALSE)
  readme2 <- readLines("docs/README.md", warn = FALSE)
  expect_false(identical(readme1, readme2))
  update_docs(path = getwd())
  readme2 <- readLines("docs/README.md", warn = FALSE)
  expect_true(identical(readme1, readme2))
})

test_that("mkdocs: update_docs updates correctly the README", {
  skip_mkdocs()
  create_local_package()
  use_mkdocs(path = getwd())
  usethis::use_readme_md()
  readme1 <- readLines("README.md", warn = FALSE)
  readme2 <- readLines("docs/docs/README.md", warn = FALSE)
  expect_false(identical(readme1, readme2))
  update_docs(path = getwd())
  readme2 <- readLines("docs/docs/README.md", warn = FALSE)
  expect_true(identical(readme1, readme2))
})



# NEWS --------------------------------------------------------

test_that("docute: update_docs updates correctly the NEWS", {
  create_local_package()
  usethis::use_news_md()
  writeLines("Hello", con = "NEWS.md")
  use_docute(path = getwd())
  writeLines("Hello again", con = "NEWS.md")
  news1 <- readLines("NEWS.md", warn = FALSE)
  news2 <- readLines("docs/NEWS.md", warn = FALSE)
  expect_false(identical(news1, news2))

  update_docs(path = getwd())
  news2 <- readLines("docs/NEWS.md", warn = FALSE)
  expect_true(identical(news1, news2))
})

test_that("docsify: update_docs updates correctly the NEWS", {
  create_local_package()
  usethis::use_news_md()
  writeLines("Hello", con = "NEWS.md")
  use_docsify(path = getwd())
  writeLines("Hello again", con = "NEWS.md")
  news1 <- readLines("NEWS.md", warn = FALSE)
  news2 <- readLines("docs/NEWS.md", warn = FALSE)
  expect_false(identical(news1, news2))

  update_docs(path = getwd())
  news2 <- readLines("docs/NEWS.md", warn = FALSE)
  expect_true(identical(news1, news2))
})

test_that("mkdocs: update_docs updates correctly the NEWS", {
  skip_mkdocs()
  create_local_package()
  usethis::use_news_md()
  writeLines("Hello", con = "NEWS.md")
  use_mkdocs(path = getwd())
  writeLines("Hello again", con = "NEWS.md")
  news1 <- readLines("NEWS.md", warn = FALSE)
  news2 <- readLines("docs/docs/NEWS.md", warn = FALSE)
  expect_false(identical(news1, news2))

  update_docs(path = getwd())
  news2 <- readLines("docs/docs/NEWS.md", warn = FALSE)
  expect_true(identical(news1, news2))
})

test_that("docsify: update_docs works when NEWS didn't exist", {
  create_local_package()
  use_docsify(path = getwd())
  usethis::use_news_md()
  expect_message(update_docs(path = getwd()),
                 regexp = "'NEWS / Changelog' was imported for the first time.")
  expect_true(fs::file_exists("docs/NEWS.md"))
})

test_that("docute: update_docs works when NEWS didn't exist", {
  create_local_package()
  use_docute(path = getwd())
  usethis::use_news_md()
  expect_message(update_docs(path = getwd()),
                 regexp = "'NEWS / Changelog' was imported for the first time.")
  expect_true(fs::file_exists("docs/NEWS.md"))
})

test_that("mkdocs: update_docs works when NEWS didn't exist", {
  skip_mkdocs()
  create_local_package()
  use_mkdocs(path = getwd())
  usethis::use_news_md()
  expect_message(update_docs(path = getwd()),
                 regexp = "'NEWS / Changelog' was imported for the first time.")
  expect_true(fs::file_exists("docs/docs/NEWS.md"))
})

test_that("docsify: update_docs shows message when NEWS doesn't exist", {
  create_local_package()
  use_docsify(path = getwd())
  expect_message(update_docs(path = getwd()),
                 regexp = "No 'NEWS / Changelog' to include.")
})

test_that("docute: update_docs shows message when NEWS doesn't exist", {
  create_local_package()
  use_docute(path = getwd())
  expect_message(update_docs(path = getwd()),
                 regexp = "No 'NEWS / Changelog' to include.")
})

test_that("mkdocs: update_docs shows message when NEWS doesn't exist", {
  skip_mkdocs()
  create_local_package()
  use_mkdocs(path = getwd())
  expect_message(update_docs(path = getwd()),
                 regexp = "No 'NEWS / Changelog' to include.")
})




# CODE OF CONDUCT --------------------------------------------------------

test_that("docute: update_docs updates correctly the CoC", {
  create_local_package()
  usethis::use_code_of_conduct("etienne.bacher@protonmail.com")
  writeLines("Hello", con = "CODE_OF_CONDUCT.md")
  use_docute(path = getwd())
  writeLines("Hello again", con = "CODE_OF_CONDUCT.md")
  news1 <- readLines("CODE_OF_CONDUCT.md", warn = FALSE)
  news2 <- readLines("docs/CODE_OF_CONDUCT.md", warn = FALSE)
  expect_false(identical(news1, news2))

  update_docs(path = getwd())
  news2 <- readLines("docs/CODE_OF_CONDUCT.md", warn = FALSE)
  expect_true(identical(news1, news2))
})

test_that("docsify: update_docs updates correctly the CoC", {
  create_local_package()
  usethis::use_code_of_conduct("etienne.bacher@protonmail.com")
  writeLines("Hello", con = "CODE_OF_CONDUCT.md")
  use_docsify(path = getwd())
  writeLines("Hello again", con = "CODE_OF_CONDUCT.md")
  news1 <- readLines("CODE_OF_CONDUCT.md", warn = FALSE)
  news2 <- readLines("docs/CODE_OF_CONDUCT.md", warn = FALSE)
  expect_false(identical(news1, news2))

  update_docs(path = getwd())
  news2 <- readLines("docs/CODE_OF_CONDUCT.md", warn = FALSE)
  expect_true(identical(news1, news2))
})

test_that("mkdocs: update_docs updates correctly the CoC", {
  skip_mkdocs()
  create_local_package()
  usethis::use_code_of_conduct("etienne.bacher@protonmail.com")
  writeLines("Hello", con = "CODE_OF_CONDUCT.md")
  use_mkdocs(path = getwd())
  writeLines("Hello again", con = "CODE_OF_CONDUCT.md")
  news1 <- readLines("CODE_OF_CONDUCT.md", warn = FALSE)
  news2 <- readLines("docs/docs/CODE_OF_CONDUCT.md", warn = FALSE)
  expect_false(identical(news1, news2))

  update_docs(path = getwd())
  news2 <- readLines("docs/docs/CODE_OF_CONDUCT.md", warn = FALSE)
  expect_true(identical(news1, news2))
})

test_that("docsify: update_docs works when CoC didn't exist", {
  create_local_package()
  use_docsify(path = getwd())
  usethis::use_code_of_conduct("etienne.bacher@protonmail.com")
  expect_message(update_docs(path = getwd()),
                 regexp = "'Code of Conduct' was imported for the first time.")
  expect_true(fs::file_exists("docs/CODE_OF_CONDUCT.md"))
})

test_that("docute: update_docs works when CoC didn't exist", {
  create_local_package()
  use_docute(path = getwd())
  usethis::use_code_of_conduct("etienne.bacher@protonmail.com")
  expect_message(update_docs(path = getwd()),
                 regexp = "'Code of Conduct' was imported for the first time.")
  expect_true(fs::file_exists("docs/CODE_OF_CONDUCT.md"))
})

test_that("mkdocs: update_docs works when CoC didn't exist", {
  skip_mkdocs()
  create_local_package()
  use_mkdocs(path = getwd())
  usethis::use_code_of_conduct("etienne.bacher@protonmail.com")
  expect_message(update_docs(path = getwd()),
                 regexp = "'Code of Conduct' was imported for the first time.")
  expect_true(fs::file_exists("docs/docs/CODE_OF_CONDUCT.md"))
})

test_that("docsify: update_docs shows message when CoC doesn't exist", {
  create_local_package()
  use_docsify(path = getwd())
  expect_message(update_docs(path = getwd()),
                 regexp = "No 'Code of Conduct' to include.")
})

test_that("docute: update_docs shows message when CoC doesn't exist", {
  create_local_package()
  use_docute(path = getwd())
  expect_message(update_docs(path = getwd()),
                 regexp = "No 'Code of Conduct' to include.")
})

test_that("mkdocs: update_docs shows message when CoC doesn't exist", {
  skip_mkdocs()
  create_local_package()
  use_mkdocs(path = getwd())
  expect_message(update_docs(path = getwd()),
                 regexp = "No 'Code of Conduct' to include.")
})





# LICENSE --------------------------------------------------------

test_that("docute: update_docs updates correctly the License", {
  create_local_package()
  usethis::use_mit_license("etienne.bacher@protonmail.com")
  writeLines("Hello", con = "LICENSE.md")
  use_docute(path = getwd())
  writeLines("Hello again", con = "LICENSE.md")
  news1 <- readLines("LICENSE.md", warn = FALSE)
  news2 <- readLines("docs/LICENSE.md", warn = FALSE)
  expect_false(identical(news1, news2))

  update_docs(path = getwd())
  news2 <- readLines("docs/LICENSE.md", warn = FALSE)
  expect_true(identical(news1, news2))
})

test_that("docsify: update_docs updates correctly the License", {
  create_local_package()
  usethis::use_mit_license("etienne.bacher@protonmail.com")
  writeLines("Hello", con = "LICENSE.md")
  use_docsify(path = getwd())
  writeLines("Hello again", con = "LICENSE.md")
  news1 <- readLines("LICENSE.md", warn = FALSE)
  news2 <- readLines("docs/LICENSE.md", warn = FALSE)
  expect_false(identical(news1, news2))

  update_docs(path = getwd())
  news2 <- readLines("docs/LICENSE.md", warn = FALSE)
  expect_true(identical(news1, news2))
})

test_that("mkdocs: update_docs updates correctly the License", {
  skip_mkdocs()
  create_local_package()
  usethis::use_mit_license("etienne.bacher@protonmail.com")
  writeLines("Hello", con = "LICENSE.md")
  use_mkdocs(path = getwd())
  writeLines("Hello again", con = "LICENSE.md")
  news1 <- readLines("LICENSE.md", warn = FALSE)
  news2 <- readLines("docs/docs/LICENSE.md", warn = FALSE)
  expect_false(identical(news1, news2))

  update_docs(path = getwd())
  news2 <- readLines("docs/docs/LICENSE.md", warn = FALSE)
  expect_true(identical(news1, news2))
})

test_that("docsify: update_docs works when License didn't exist", {
  create_local_package()
  use_docsify(path = getwd())
  usethis::use_mit_license("etienne.bacher@protonmail.com")
  expect_message(update_docs(path = getwd()),
                 regexp = "'License / Licence' was imported for the first time.")
  expect_true(fs::file_exists("docs/LICENSE.md"))
})

test_that("docute: update_docs works when License didn't exist", {
  create_local_package()
  use_docute(path = getwd())
  usethis::use_mit_license("etienne.bacher@protonmail.com")
  expect_message(update_docs(path = getwd()),
                 regexp = "'License / Licence' was imported for the first time.")
  expect_true(fs::file_exists("docs/LICENSE.md"))
})

test_that("mkdocs: update_docs works when License didn't exist", {
  skip_mkdocs()
  create_local_package()
  use_mkdocs(path = getwd())
  usethis::use_mit_license("etienne.bacher@protonmail.com")
  expect_message(update_docs(path = getwd()),
                 regexp = "'License / Licence' was imported for the first time.")
  expect_true(fs::file_exists("docs/docs/LICENSE.md"))
})

test_that("docsify: update_docs shows message when License doesn't exist", {
  create_local_package()
  use_docsify(path = getwd())
  expect_message(update_docs(path = getwd()),
                 regexp = "No 'License / Licence' to include.")
})

test_that("docute: update_docs shows message when License doesn't exist", {
  create_local_package()
  use_docute(path = getwd())
  expect_message(update_docs(path = getwd()),
                 regexp = "No 'License / Licence' to include.")
})

test_that("mkdocs: update_docs shows message when License doesn't exist", {
  skip_mkdocs()
  create_local_package()
  use_mkdocs(path = getwd())
  expect_message(update_docs(path = getwd()),
                 regexp = "No 'License / Licence' to include.")
})



# VIGNETTES --------------------------------------------------------

test_that("docute: update_docs also transform new/modified vignettes if specified", {
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
  use_docute(convert_vignettes = TRUE, path = getwd())
  writeLines(second_rmd, "vignettes/several-outputs.Rmd")

  expect_false(fs::file_exists("docs/articles/several-outputs.md"))
  update_docs(convert_vignettes = TRUE, path = getwd())
  expect_true(fs::file_exists("docs/articles/several-outputs.md"))
})

test_that("docsify: update_docs also transform new/modified vignettes if specified", {
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
  use_docsify(convert_vignettes = TRUE, path = getwd())
  writeLines(second_rmd, "vignettes/several-outputs.Rmd")

  expect_false(fs::file_exists("docs/articles/several-outputs.md"))
  update_docs(convert_vignettes = TRUE, path = getwd())
  expect_true(fs::file_exists("docs/articles/several-outputs.md"))
})

test_that("mkdocs: update_docs also transform new/modified vignettes if specified", {
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
  use_mkdocs(convert_vignettes = TRUE, path = getwd())
  writeLines(second_rmd, "vignettes/several-outputs.Rmd")

  expect_false(fs::file_exists("docs/docs/articles/several-outputs.md"))
  update_docs(convert_vignettes = TRUE, path = getwd())
  expect_true(fs::file_exists("docs/docs/articles/several-outputs.md"))
})

