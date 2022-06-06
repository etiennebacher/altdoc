test_that("nothing changes if no vignettes folder or if empty", {
  create_local_package()
  use_docute(convert_vignettes = FALSE, path = getwd())
  before <- fs::dir_tree("docs")
  transform_vignettes(path = getwd())
  after1 <- fs::dir_tree("docs")
  fs::dir_create("vignettes")
  transform_vignettes(path = getwd())
  after2 <- fs::dir_tree("docs")

  expect_identical(before, after1)
  expect_identical(before, after2)
})

test_that("transform_vignettes works on basic vignette", {
  original_rmd <- readLines(
    testthat::test_path("examples/examples-yaml", "basic.Rmd"),
    warn = FALSE
  )
  create_local_package()
  use_docute(path = getwd())
  fs::dir_create("vignettes")
  writeLines(original_rmd, "vignettes/basic.Rmd")
  expect_message(transform_vignettes(path = getwd()), regexp = "has been converted")
  expect_true(fs::file_exists("docs/articles/basic.Rmd"))
  expect_true(fs::file_exists("docs/articles/basic.md"))
})

test_that("transform_vignettes doesn't change anything if no change in vignettes", {
  original_rmd <- readLines(
    testthat::test_path("examples/examples-yaml", "basic.Rmd"),
    warn = FALSE
  )
  create_local_package()
  use_docute(path = getwd())
  fs::dir_create("vignettes")
  writeLines(original_rmd, "vignettes/basic.Rmd")
  transform_vignettes(path = getwd())
  before <- fs::dir_tree()
  vignette_before <- readLines("docs/articles/basic.Rmd", warn = FALSE)
  expect_message(transform_vignettes(path = getwd()), regexp = "No new vignette to convert")
  after <- fs::dir_tree()
  vignette_after <- readLines("docs/articles/basic.Rmd", warn = FALSE)
  expect_identical(before, after)
  expect_identical(vignette_before, vignette_after)
})
