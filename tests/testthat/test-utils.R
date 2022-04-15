test_that("folder_is_empty() works", {
  create_local_package()
  dir_create("docs")
  expect_true(folder_is_empty("docs"))

  file_create("docs/test.md")
  expect_false(folder_is_empty("docs"))
})

test_that("check_docs_exists() works", {
  create_local_package()
  expect_silent(check_docs_exists())

  dir_create("docs")
  expect_silent(check_docs_exists())

  file_create("docs/test.md")
  expect_error(check_docs_exists())
})

test_that("pkg_name() works", {
  create_local_package()
  expect_true(is.character(pkg_name()))
  expect_true(nchar(pkg_name()) > 0)
})

test_that("pkg_version() works", {
  create_local_package()
  expect_true(is.character(pkg_version()))
  expect_true(nchar(pkg_version()) > 0)
})

test_that("import_* functions work", {
  create_local_package()
  dir_create("docs")
  cat("docute", file = "docs/index.html")

  usethis::use_readme_md()
  expect_false(file_exists("docs/README.md"))
  import_readme()
  expect_true(file_exists("docs/README.md"))

  usethis::use_code_of_conduct("etienne.bacher@protonmail.com")
  expect_false(file_exists("docs/CODE_OF_CONDUCT.md"))
  import_coc()
  expect_true(file_exists("docs/CODE_OF_CONDUCT.md"))

  usethis::use_news_md()
  expect_false(file_exists("docs/NEWS.md"))
  import_news()
  expect_true(file_exists("docs/NEWS.md"))

})
