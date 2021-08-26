test_that("nothing is done if 'docs' is not empty", {
  create_local_package()
  fs::dir_create("docs")
  fs::file_create("docs/test.md")

  package_structure_before <- fs::dir_ls(recurse = TRUE)
  expect_error(use_docute())
  package_structure_after <- fs::dir_ls(recurse = TRUE)

  expect_true(identical(package_structure_before, package_structure_after))
})
