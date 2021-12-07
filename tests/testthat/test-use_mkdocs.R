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
  yaml <- paste(readLines("docs/mkdocs.yml", warn = FALSE), collapse = "")
  expect_true(grepl("name: readthedocs", yaml))
})

test_that("argument theme works", {
  create_local_package()
  use_mkdocs(theme = "material")
  yaml <- paste(readLines("docs/mkdocs.yml", warn = FALSE), collapse = "")
  expect_true(grepl("name: material", yaml))
})
