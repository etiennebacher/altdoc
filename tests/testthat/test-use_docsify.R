# Don't know how to test yesno message after use_docsify

test_that("use_docute creates the right files", {
  create_local_package()
  use_docsify()
  expect_true(fs::file_exists("docs/index.html"))
  expect_true(fs::file_exists("docs/README.md"))
  expect_true(fs::file_exists("docs/reference.md"))
})

