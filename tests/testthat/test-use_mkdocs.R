skip_mkdocs()

test_that("use_mkdocs creates the right files", {
  create_local_package()
  setup_docs(tool = "mkdocs", path = getwd())
  render_docs(path = getwd())
  expect_true(fs::file_exists("docs/mkdocs.yml"))
  expect_true(fs::file_exists("docs/README.md"))
})

test_that("use_mkdocs: arg 'overwrite' works", {
  create_local_package()
  setup_docs(tool = "mkdocs", path = getwd())
  fs::file_create("altdoc/test")
  setup_docs(tool = "mkdocs", overwrite = TRUE, path = getwd())
  expect_false(fs::file_exists("altdoc/test"))
})
