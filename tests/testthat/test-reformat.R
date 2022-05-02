test_that("reformat_md works", {

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
  reformat_md(tmp)
  prod <- readLines(tmp, warn = FALSE)
  ref <- readLines(testthat::test_path("examples/examples-reformat/after-first-false.md"), warn = FALSE)

  expect_identical(prod, ref)
})

test_that("reformat_md: arg 'first' works", {

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
  reformat_md(tmp, first = TRUE)
  prod <- readLines(tmp, warn = FALSE)
  ref <- readLines(testthat::test_path("examples/examples-reformat/after-first-true.md"), warn = FALSE)

  expect_identical(prod, ref)
})
