test_that("Custom rd2md works", {

  # Need to write and read to avoid all \n differences
  tmp <- fs::file_temp(ext = ".md")
  prod <- rd2md(testthat::test_path("examples/examples-man/between.Rd"))
  prod <- writeLines(prod, tmp)
  prod <- readLines(tmp, warn = FALSE)

  ref <- readLines(testthat::test_path("examples/examples-man/between.md"), warn = FALSE)

  expect_identical(prod, ref)
})

