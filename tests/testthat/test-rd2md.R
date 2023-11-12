### NOT RUNNING ON GHA, don't know why

# test_that("Custom .rd2md works", {
#
#   # Need to write and read to avoid all \n differences
#   tmp <- fs::file_temp(ext = ".md")
#   prod <- .rd2md(testthat::test_path("examples/examples-man/between.Rd"))
#   prod <- writeLines(prod, tmp)
#   # remove the header because it changes depending on whether test on cran
#   # or on local machine
#   prod <- .readlines(tmp)[-1]
#
#   ref <- .readlines(testthat::test_path("examples/examples-man/between.md"))
#
#   expect_identical(prod, ref)
# })
