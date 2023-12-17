# Don't know how to test yesno message after use_docsify

test_that("use_docsify creates the right files", {
  create_local_package()
  setup_docs(tool = "docsify")
  render_docs()
  expect_true(fs::file_exists("docs/index.html"))
  expect_true(fs::file_exists("docs/README.md"))
})
