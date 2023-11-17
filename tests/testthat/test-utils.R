test_that(".folder_is_empty() works", {
  create_local_package()
  fs::dir_create("docs")
  expect_true(.folder_is_empty("docs"))

  fs::file_create("docs/test.md")
  expect_false(.folder_is_empty("docs"))
})

test_that(".check_docs_exists() works", {
  create_local_package()
  expect_silent(.check_docs_exists())

  fs::dir_create("docs")
  expect_silent(.check_docs_exists())

  ## Test disabled because we now prompt for overwriting instead of erroring
  # fs::file_create("docs/test.md")
  # expect_error(.check_docs_exists())
})

test_that(".pkg_name() works", {
  create_local_package()
  expect_true(is.character(.pkg_name(getwd())))
  expect_true(nchar(.pkg_name(getwd())) > 0)
})

test_that(".pkg_version() works", {
  create_local_package()
  expect_true(is.character(.pkg_version(".")))
  expect_true(nchar(.pkg_version(".")) > 0)
})

