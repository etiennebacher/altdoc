test_that("modify_yaml works on basic yaml", {

  # don't directly modify the example
  tmp <- tempfile()
  fs::file_copy(
    testthat::test_path("examples/examples-yaml", "basic.Rmd"),
    tmp
  )

  original_yaml <- yaml::read_yaml(tmp)
  modify_yaml(tmp)
  new_yaml <- yaml::read_yaml(tmp)

  expect_identical(names(new_yaml$output), "github_document")
  expect_identical(new_yaml$output$github_document, "default")
  expect_null(new_yaml$vignette)
  expect_identical(original_yaml$title, new_yaml$title)
})

test_that("modify_yaml works with other options", {

  # don't directly modify the example
  tmp <- tempfile()
  fs::file_copy(
    testthat::test_path("examples/examples-yaml", "options.Rmd"),
    tmp
  )

  original_yaml <- yaml::read_yaml(tmp)
  modify_yaml(tmp)
  new_yaml <- yaml::read_yaml(tmp)

  expect_identical(names(new_yaml$output), "github_document")
  expect_identical(new_yaml$output$github_document, "default")
  expect_null(new_yaml$vignette)
  expect_identical(original_yaml$title, new_yaml$title)
  expect_identical(original_yaml$author, new_yaml$author)
  expect_identical(original_yaml$date, new_yaml$date)
  expect_identical(original_yaml$editor_options, new_yaml$editor_options)
  expect_identical(original_yaml$bibliography, new_yaml$bibliography)
})


test_that("modify_yaml only removes html output and keep other formats options", {

  # don't directly modify the example
  tmp <- tempfile()
  fs::file_copy(
    testthat::test_path("examples/examples-yaml", "several-outputs.Rmd"),
    tmp
  )

  original_yaml <- yaml::read_yaml(tmp)
  modify_yaml(tmp)
  new_yaml <- yaml::read_yaml(tmp)

  expect_true(length(new_yaml$output) == 2)
  expect_equal(names(new_yaml$output), c("github_document", "rmarkdown::pdf_document"))
  expect_identical(
    original_yaml$output$`rmarkdown::pdf_document`$engine,
    new_yaml$output$`rmarkdown::pdf_document`$engine
  )
})

test_that("extract_import_bib works", {
  original_rmd <- readLines(testthat::test_path("examples/examples-yaml", "options.Rmd"))
  create_local_package()
  use_docute(path = getwd())

  # create vignette and bib file
  fs::dir_create("vignettes")
  writeLines(original_rmd, "vignettes/options.Rmd")
  fs::file_create("vignettes/bibliography.bib")
  writeLines("hello this is the biblio", "vignettes/bibliography.bib")
  fs::dir_create("docs/articles")
  extract_import_bib("vignettes/options.Rmd", path = getwd())

  expect_true(fs::file_exists("docs/articles/bibliography.bib"))
  bib <- readLines("docs/articles/bibliography.bib", warn = FALSE)
  expect_true(bib == "hello this is the biblio")
})
