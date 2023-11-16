# Don't know how to test yesno message after use_docute

test_that("use_docute creates the right files", {
  create_local_package()
  setup_docs(tool = "docute", path = getwd())
  render_docs(path = getwd())
  expect_true(fs::file_exists("docs/index.html"))
  expect_true(fs::file_exists("docs/README.md"))
})
