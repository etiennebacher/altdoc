test_that(".rd2qmd works", {
  rd_file <- testthat::test_path("examples/examples-man/between.Rd")
  # .rd2qmd works only in pkg directory
  fs::file_create("DESCRIPTION")
  dest <- tempdir()
  .rd2qmd(rd_file, dest, path = ".")
  qmd_file <- fs::path_join(c(dest, "between.qmd"))
  expect_true(fs::file_exists(qmd_file))

  content <- .readlines(qmd_file)
  h3 <- grep("^### ", content, value = TRUE)
  expect_equal(
    h3,
    c("### Description", "### Usage", "### Arguments")
  )

  h2 <- grep("^## ", content, value = TRUE)
  expect_equal(h2, "## Do values in a numeric vector fall in specified range? {.unnumbered}")
})

test_that(".rd2qmd: basic errors", {
  expect_error(
    .rd2qmd("foo"),
    "must be a valid file path"
  )
  expect_error(
    .rd2qmd(testthat::test_path("examples/examples-man/between.Rd"), "foo", path = "."),
    "must be a valid directory"
  )
})
