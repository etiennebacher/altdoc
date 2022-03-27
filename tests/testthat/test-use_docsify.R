# Don't know how to test yesno message after use_docsify

test_that("use_docsify creates the right files", {
  create_local_package()
  use_docsify()
  expect_true(fs::file_exists("docs/index.html"))
  expect_true(fs::file_exists("docs/README.md"))
  expect_true(fs::file_exists("docs/reference.md"))
})

test_that("use_docsify: arg 'overwrite' works", {
  create_local_package()
  use_docsify()
  fs::file_create("docs/test")
  use_docsify(overwrite = TRUE)
  expect_false(fs::file_exists("docs/test"))
})

