# Don't know how to test yesno message after use_docute

test_that("use_docute creates the right files", {
  create_local_package()
  use_docute()
  expect_true(file_exists("docs/index.html"))
  expect_true(file_exists("docs/README.md"))
  expect_true(file_exists("docs/reference.md"))
})

test_that("use_docute: arg 'overwrite' works", {
  create_local_package()
  use_docute()
  file_create("docs/test")
  use_docute(overwrite = TRUE)
  expect_false(file_exists("docs/test"))
})
