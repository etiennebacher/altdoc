test_that("use template preamble if no preamble in file", {
  source <- tempfile(fileext = ".qmd")
  fs::file_copy(test_path("examples/examples-qmd/without-preamble.qmd"), source)
  create_local_package()
  setup_docs("docute")
  fs::dir_create("vignettes")
  fs::file_copy(source, "vignettes")
  preamble <- .readlines("altdoc/preamble_vignettes_qmd.yml")
  vignette_qmd <- list.files("vignettes", full.names = TRUE)[1]

  .qmd2md(vignette_qmd, "vignettes", preamble = preamble)
  vignette_md <- list.files("vignettes", full.names = TRUE, pattern = "\\.md$")[1]

  # we use our preamble so quarto shouldn't automatically add the ".png" extension
  content <- .readlines(vignette_md)
  expect_true(any(grepl("badges/plot2)", content, fixed = TRUE)))
})

test_that("do not use template preamble if preamble in file", {
  source <- tempfile(fileext = ".qmd")
  fs::file_copy(test_path("examples/examples-qmd/with-preamble.qmd"), source)
  create_local_package()
  setup_docs("docute")
  fs::dir_create("vignettes")
  fs::file_copy(source, "vignettes")
  preamble <- .readlines("altdoc/preamble_vignettes_qmd.yml")
  vignette_qmd <- list.files("vignettes", full.names = TRUE)[1]
  .qmd2md(vignette_qmd, "vignettes", preamble = preamble)

  vignette_md <- list.files("vignettes", full.names = TRUE, pattern = "\\.md$")[1]

  # there's already a preamble so we don't use ours. Quarto should automatically
  # add the ".png" extension
  content <- .readlines(vignette_md)
  expect_true(any(grepl("badges/plot2.png)", content, fixed = TRUE)))
})
