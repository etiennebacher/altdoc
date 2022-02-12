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
  cat("Hello", file = "NEWS.md")
  use_docute()
  cat("Hello again", file = "NEWS.md")
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
  cat("Hello", file = "NEWS.md")
  use_docsify()
  cat("Hello again", file = "NEWS.md")
  news1 <- readLines("NEWS.md", warn = FALSE)
  news2 <- readLines("docs/NEWS.md", warn = FALSE)
  expect_false(identical(news1, news2))

  update_docs()
  news2 <- readLines("docs/NEWS.md", warn = FALSE)
  expect_true(identical(news1, news2))
})

test_that("mkdocs: update_docs updates correctly the NEWS", {
  create_local_package()
  usethis::use_news_md()
  cat("Hello", file = "NEWS.md")
  use_mkdocs()
  cat("Hello again", file = "NEWS.md")
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
  expect_message(update_docs())
})

test_that("docute: update_docs shows message when NEWS didn't exist", {
  create_local_package()
  use_docute()
  usethis::use_news_md()
  expect_message(update_docs())
})

test_that("mkdocs: update_docs shows message when NEWS didn't exist", {
  create_local_package()
  use_mkdocs()
  usethis::use_news_md()
  expect_message(update_docs())
})
