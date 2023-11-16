skip_mkdocs()

test_that("use_mkdocs creates the right files", {
  create_local_package()
  setup_docs(tool = "mkdocs", path = getwd())
  render_docs(path = getwd())
  expect_true(fs::file_exists("docs/mkdocs.yml"))
  expect_true(fs::file_exists("docs/README.md"))
})
