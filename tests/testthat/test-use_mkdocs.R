skip_mkdocs()

test_that("use_mkdocs creates the right files", {
  create_local_package()
  use_mkdocs()
  expect_true(file_exists("docs/mkdocs.yml"))
  expect_true(file_exists("docs/docs/README.md"))
  expect_true(file_exists("docs/docs/reference.md"))
})

test_that("use_mkdocs: arg 'overwrite' works", {
  create_local_package()
  use_mkdocs()
  file_create("docs/test")
  use_mkdocs(overwrite = TRUE)
  expect_false(file_exists("docs/test"))
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
