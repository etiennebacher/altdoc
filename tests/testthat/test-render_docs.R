test_that("docute: main files are correct", {
  skip_on_cran()

  ### setup: create a temp package using the structure of testpkg.altdoc
  path_to_example_pkg <- fs::path_abs(test_path("examples/testpkg.altdoc"))
  create_local_project()
  fs::dir_delete("R")
  fs::dir_copy(path_to_example_pkg, ".")
  all_files <- list.files("testpkg.altdoc", full.names = TRUE)
  for (i in all_files) {
    fs::file_move(i, ".")
  }
  fs::dir_delete("testpkg.altdoc")

  ### generate docs
  install.packages(".", repos = NULL, type = "source")
  setup_docs("docute")
  render_docs()

  ### test
  expect_snapshot(.readlines("docs/README.md"))
  expect_snapshot(.readlines("docs/docute.html"))
  expect_snapshot(.readlines("docs/NEWS.md"))
  expect_snapshot(.readlines("docs/man/hello_base.md"))
  expect_snapshot(.readlines("docs/man/hello_r6.md"))
  expect_snapshot(.readlines("docs/vignettes/test.md"))
})



test_that("docsify: main files are correct", {
  skip_on_cran()

  ### setup: create a temp package using the structure of testpkg.altdoc
  path_to_example_pkg <- fs::path_abs(test_path("examples/testpkg.altdoc"))
  create_local_project()
  fs::dir_delete("R")
  fs::dir_copy(path_to_example_pkg, ".")
  all_files <- list.files("testpkg.altdoc", full.names = TRUE)
  for (i in all_files) {
    fs::file_move(i, ".")
  }
  fs::dir_delete("testpkg.altdoc")

  ### generate docs
  install.packages(".", repos = NULL, type = "source")
  setup_docs("docsify")
  render_docs()

  ### test
  expect_snapshot(.readlines("docs/README.md"))
  expect_snapshot(.readlines("docs/_sidebar.md"))
  expect_snapshot(.readlines("docs/index.html"))
  expect_snapshot(.readlines("docs/NEWS.md"))
  expect_snapshot(.readlines("docs/man/hello_base.md"))
  expect_snapshot(.readlines("docs/man/hello_r6.md"))
  expect_snapshot(.readlines("docs/vignettes/test.md"))
})

### Quarto output changes depending on the version, I don't have a solution for
### now.

# test_that("quarto: main files are correct", {
#   skip_on_cran()
#
#   ### setup: create a temp package using the structure of testpkg.altdoc
#   path_to_example_pkg <- fs::path_abs(test_path("examples/testpkg.altdoc"))
#   create_local_project()
#   fs::dir_delete("R")
#   fs::dir_copy(path_to_example_pkg, ".")
#   all_files <- list.files("testpkg.altdoc", full.names = TRUE)
#   for (i in all_files) {
#     fs::file_move(i, ".")
#   }
#   fs::dir_delete("testpkg.altdoc")
#
#   ### generate docs
#   install.packages(".", repos = NULL, type = "source")
#   fs::file_move("README.Rmd", "README.qmd") # special thing quarto
#   setup_docs("quarto_website")
#   render_docs()
#
#   ### test
#   expect_snapshot(.readlines("docs/index.html"))
#   expect_snapshot(.readlines("docs/NEWS.html"))
#   expect_snapshot(.readlines("docs/man/hello_base.html"))
#   expect_snapshot(.readlines("docs/man/hello_r6.html"))
#   expect_snapshot(.readlines("docs/vignettes/test.html"))
# })
