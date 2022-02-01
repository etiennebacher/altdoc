# This requires installing pip3 and mkdocs, which is not possible on CRAN
# (to my knowledge)
skip_on_cran()
skip_on_ci()
skip_if_not(is_mkdocs())

test_that("use_mkdocs creates the right files", {
  create_local_package()
  use_mkdocs()
  expect_true(fs::file_exists("docs/mkdocs.yml"))
  expect_true(fs::file_exists("docs/docs/README.md"))
  expect_true(fs::file_exists("docs/docs/reference.md"))
})

test_that("argument theme works", {
  create_local_package()
  use_mkdocs(theme = "readthedocs")
  path <- getwd()
  yaml <- paste(readLines(paste0(path, "/docs/mkdocs.yml"), warn = FALSE), collapse = "")
  expect_true(grepl("name: readthedocs", yaml))
})

test_that("argument theme works", {
  create_local_package()
  use_mkdocs(theme = "material")
  path <- getwd()
  yaml <- paste(readLines(paste0(path, "/docs/mkdocs.yml"), warn = FALSE), collapse = "")
  expect_true(grepl("name: material", yaml))
})
