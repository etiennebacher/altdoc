skip_mkdocs()

test_that("use_mkdocs creates the right files", {
  create_local_package()
  setup_docs(tool = "mkdocs", path = getwd())
  expect_true(fs::file_exists("docs/mkdocs.yml"))
  expect_true(fs::file_exists("docs/docs/README.md"))
  expect_true(fs::file_exists("docs/docs/reference.md"))
})

test_that("use_mkdocs: arg 'overwrite' works", {
  create_local_package()
  setup_docs(tool = "mkdocs", path = getwd())
  fs::file_create("docs/test")
  use_mkdocs(overwrite = TRUE, path = getwd())
  expect_false(fs::file_exists("docs/test"))
})

test_that("argument theme works", {
  create_local_package()
  use_mkdocs(theme = "readthedocs", path = getwd())
  path <- getwd()
  yaml <- paste(.readlines(fs::path_abs("docs/mkdocs.yml", start = path)), collapse = "")
  expect_true(grepl("name: readthedocs", yaml))
})

test_that("argument theme works", {
  skip_if_not(.is_mkdocs_material())
  create_local_package()
  use_mkdocs(theme = "material", path = getwd())
  path <- getwd()
  yaml <- paste(.readlines(fs::path_abs("docs/mkdocs.yml", start = path)), collapse = "")
  expect_true(grepl("name: material", yaml))
})
