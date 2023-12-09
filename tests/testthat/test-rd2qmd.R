test_that(".rd2qmd works", {
  rd_file <- testthat::test_path("examples/examples-man/between.Rd")
  dest <- tempdir()
  .rd2qmd(rd_file, dest)
  qmd_file <- fs::path_join(c(dest, "between.qmd"))
  expect_true(fs::file_exists(qmd_file))

  content <- .readlines(qmd_file)
  h3 <- grep("^### ", content, value = TRUE)
  expect_equal(
    h3,
    c("### Description", "### Usage", "### Arguments", "### Examples")
  )

  h2 <- grep("^## ", content, value = TRUE)
  expect_equal(h2, "## Do values in a numeric vector fall in specified range? {.unnumbered}")

  # examples
  expect_true(any(grepl("```{r, warning=FALSE", content, fixed = TRUE)))
  expect_true(any(grepl("library(altdoc)", content, fixed = TRUE)))
})

test_that(".rd2qmd: basic errors", {
  expect_error(
    .rd2qmd("foo"),
    "must be a valid file path"
  )
  expect_error(
    .rd2qmd(testthat::test_path("examples/examples-man/between.Rd"), "foo"),
    "must be a valid directory"
  )
})
