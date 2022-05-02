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




test_that("replace_figures_rmd works", {
  # setup
  original_rmd <- readLines(
    testthat::test_path("examples/examples-vignettes", "with-figure.Rmd"),
    warn = FALSE
  )
  create_local_package()
  use_docute(convert_vignettes = FALSE)
  fs::dir_create("vignettes/figures")
  fs::dir_create("docs/articles/figures")
  download.file("https://raw.githubusercontent.com/etiennebacher/conductor/master/hex-conductor.png", "vignettes/hex-conductor.png", mode = if(.Platform$OS.type == "windows") "wb")
  download.file("https://raw.githubusercontent.com/etiennebacher/conductor/master/hex-conductor.png", "vignettes/figures/hex-conductor-2.png", mode = if(.Platform$OS.type == "windows") "wb")
  writeLines(original_rmd, "vignettes/with-figure.Rmd")

  replace_figures_rmd()
  expect_true(fs::file_exists("docs/articles/figures/hex-conductor.png"))
  expect_true(fs::file_exists("docs/articles/figures/hex-conductor-2.png"))
})
