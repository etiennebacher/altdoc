test_that(".reformat_md works", {
  # Need to write and read to avoid all \n differences
  tmp <- fs::file_temp(ext = ".md")
  txt <- "# Package

# Installation

Well hello there

## Stable version

Here's some code:

```r
# here's a comment
1 + 1
```

## Dev version

Hello

# Demo

Hello again
"
  cat(txt, file = tmp)
  .reformat_md(tmp)
  prod <- .readlines(tmp)
  ref <- .readlines(testthat::test_path("examples/examples-reformat/after-first-false.md"))

  expect_identical(prod, ref)
})




test_that(".reformat_md: arg 'first' works", {
  # Need to write and read to avoid all \n differences
  tmp <- fs::file_temp(ext = ".md")
  txt <- "# Package

# Installation

Well hello there

## Stable version

Here's some code:

```r
# here's a comment
1 + 1
```

## Dev version

Hello

# Demo

Hello again
"
  cat(txt, file = tmp)
  .reformat_md(tmp, first = TRUE)
  prod <- .readlines(tmp)
  ref <- .readlines(testthat::test_path("examples/examples-reformat/after-first-true.md"))

  expect_identical(prod, ref)
})
