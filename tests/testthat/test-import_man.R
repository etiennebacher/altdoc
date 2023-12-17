test_that("rendering fails", {
  source <- test_path("examples/examples-man/should-fail.Rd")
  dest <- tempfile(fileext = ".Rd")
  fs::file_copy(source, dest)

  create_local_package()
  setup_docs("docute")
  fs::dir_create("man")
  fs::file_copy(dest, "man")
  src <- fs::path_ext_remove(list.files("man"))
  expect_equal(
    .render_one_man(src, tool = "docute", src_dir = ".", tar_dir = ".", freeze = FALSE, hashes = NULL),
    "failure"
  )
})

test_that("rendering skipped because internal", {
  source <- test_path("examples/examples-man/is-internal.Rd")
  dest <- tempfile(fileext = ".Rd")
  fs::file_copy(source, dest)

  create_local_package()
  setup_docs("docute")
  fs::dir_create("man")
  fs::file_copy(dest, "man")
  src <- fs::path_ext_remove(list.files("man"))
  expect_equal(
    .render_one_man(src, tool = "docute", src_dir = ".", tar_dir = ".", freeze = FALSE, hashes = NULL),
    "skipped_internal"
  )
})

test_that("rendering skipped because unchanged and freeze = TRUE", {
  # writing freeze.rds is disabled in CI
  skip_on_ci()
  source <- test_path("examples/examples-man/between.Rd")
  dest <- tempfile(fileext = ".Rd")
  fs::file_copy(source, dest)

  create_local_package()
  setup_docs("docute")
  fs::dir_create("man")
  fs::file_copy(dest, "man")
  src <- fs::path_ext_remove(list.files("man"))

  # first rendering to store the hash
  .render_one_man(src, tool = "docute", src_dir = ".", tar_dir = ".", freeze = FALSE, hashes = NULL)
  .update_freeze(".", src, successes = 1, fails = NULL, type = "man")
  hashes <- .get_hashes(".", freeze = TRUE)

  expect_equal(
    .render_one_man(src, tool = "docute", src_dir = ".", tar_dir = ".", freeze = TRUE, hashes = hashes),
    "skipped_unchanged"
  )
})
