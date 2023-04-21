test_that("nothing changes if no vignettes folder or if empty", {
  create_local_package()
  use_docute(convert_vignettes = FALSE, path = getwd())
  before <- fs::dir_tree("docs")
  .transform_vignettes(path = getwd())
  after1 <- fs::dir_tree("docs")
  fs::dir_create("vignettes")
  .transform_vignettes(path = getwd())
  after2 <- fs::dir_tree("docs")

  expect_identical(before, after1)
  expect_identical(before, after2)
})

test_that(".transform_vignettes works on basic vignette", {
  original_rmd <- .readlines(
    testthat::test_path("examples/examples-yaml", "basic.Rmd")
  )
  create_local_package()
  use_docute(path = getwd(), convert_vignettes = FALSE)
  fs::dir_create("vignettes")
  writeLines(original_rmd, "vignettes/basic.Rmd")
  expect_message(
    .transform_vignettes(path = getwd()),
    "following vignette has been converted"
  )
  expect_message(
    .add_vignettes(path = getwd()),
    "Don't forget to check"
  )
  expect_true(fs::file_exists("docs/articles/basic.Rmd"))
  expect_true(fs::file_exists("docs/articles/basic.md"))
})
