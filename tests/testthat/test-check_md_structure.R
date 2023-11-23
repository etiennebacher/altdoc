test_that(".reformat_md works", {
  # Need to write and read to avoid all \n differences
  create_local_package()
  setup_docs(tool = "docsify", path = getwd())
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
  cat(txt, file = "README.md")
  expect_message(render_docs(), "assumes that the only level 1")
})