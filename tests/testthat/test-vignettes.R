test_that("nothing changes if no vignettes folder or if empty", {
  create_local_package()
  setup_docs(tool = "docute", path = getwd())
  before <- fs::dir_tree("docs")
  .import_vignettes(path = getwd())
  after1 <- fs::dir_tree("docs")
  fs::dir_create("vignettes")
  .import_vignettes(path = getwd())
  after2 <- fs::dir_tree("docs")

  expect_identical(before, after1)
  expect_identical(before, after2)
})

test_that(".import_vignettes works on basic vignette", {
  original_rmd <- .readlines(
    testthat::test_path("examples/examples-yaml", "basic.Rmd")
  )
  create_local_package()
  fs::dir_create("vignettes")
  writeLines(original_rmd, "vignettes/basic.Rmd")
  setup_docs(tool = "docute", path = getwd())
  expect_message(
    render_docs(path = getwd()),
    "following vignette has been rendered"
  )
  expect_true(fs::file_exists("docs/articles/basic.md"))
})
