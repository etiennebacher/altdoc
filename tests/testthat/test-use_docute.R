# Don't know how to test yesno message after use_docute

test_that("use_docute creates the right files", {
  create_local_package()
  setup_docs(tool = "docute", path = getwd())
  render_docs(path = getwd())
  expect_true(fs::file_exists("docs/index.html"))
  expect_true(fs::file_exists("docs/README.md"))
})

test_that("use_docute: arg 'overwrite' works", {
  create_local_package()
  setup_docs(tool = "docute", path = getwd())
  render_docs(path = getwd())
  fs::file_create("altdoc/test")
  setup_docs(tool = "docute", overwrite = TRUE, path = getwd())
  expect_false(fs::file_exists("altdoc/test"))
})
