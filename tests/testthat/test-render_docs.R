test_that("docute: main files are correct", {
  skip_on_cran()
  skip_if(.is_windows() && .on_ci(), "Windows on CI")

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
  render_docs(verbose = .on_ci())

  ### test
  expect_snapshot(.readlines("docs/README.md"), variant = "docute")
  expect_snapshot(.readlines("docs/docute.html"), variant = "docute")
  expect_snapshot(.readlines("docs/NEWS.md"), variant = "docute")
  expect_snapshot(.readlines("docs/man/hello_base.md"), variant = "docute")
  expect_snapshot(.readlines("docs/man/hello_r6.md"), variant = "docute")
  expect_snapshot(.readlines("docs/man/examplesIf_true.md"), variant = "docute")
  expect_snapshot(.readlines("docs/man/examplesIf_false.md"), variant = "docute")
  expect_snapshot(.readlines("docs/vignettes/test.md"), variant = "docute")
})



test_that("docsify: main files are correct", {
  skip_on_cran()
  skip_if(.is_windows() && .on_ci(), "Windows on CI")

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
  render_docs(verbose = .on_ci())

  ### test
  expect_snapshot(.readlines("docs/README.md"), variant = "docsify")
  expect_snapshot(.readlines("docs/_sidebar.md"), variant = "docsify")
  expect_snapshot(.readlines("docs/index.html"), variant = "docsify")
  expect_snapshot(.readlines("docs/NEWS.md"), variant = "docsify")
  expect_snapshot(.readlines("docs/man/hello_base.md"), variant = "docsify")
  expect_snapshot(.readlines("docs/man/hello_r6.md"), variant = "docsify")
  expect_snapshot(.readlines("docs/man/examplesIf_true.md"), variant = "docsify")
  expect_snapshot(.readlines("docs/man/examplesIf_false.md"), variant = "docsify")
  expect_snapshot(.readlines("docs/vignettes/test.md"), variant = "docsify")
})



test_that("mkdocs: main files are correct", {
  skip_on_cran()
  skip_if_offline() # we download mkdocs every time
  skip_if(.is_windows() && .on_ci(), "Windows on CI")

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

  ### special mkdocs stuff
  if (.is_windows()) {
    shell("python3 -m venv .venv_altdoc")
    shell(".venv_altdoc\\Scripts\\activate.bat && python3 -m pip install mkdocs --quiet")
  } else {
    system2("python3", "-m venv .venv_altdoc")
    system2("bash", "-c 'source .venv_altdoc/bin/activate && python3 -m pip install mkdocs --quiet'", stdout = FALSE)
  }

  ### generate docs
  install.packages(".", repos = NULL, type = "source")
  setup_docs("mkdocs")
  render_docs(verbose = .on_ci())

  ### test
  # no good way to test the site structure ("docs/mkdocs.yml" only shows
  # the old yaml, not the one with replaced variables)
  expect_snapshot(.readlines("docs/NEWS.md"), variant = "mkdocs")
  expect_snapshot(.readlines("docs/man/hello_base.md"), variant = "mkdocs")
  expect_snapshot(.readlines("docs/man/hello_r6.md"), variant = "mkdocs")
  expect_snapshot(.readlines("docs/vignettes/test.md"), variant = "mkdocs")
})



test_that("quarto: no error for basic workflow", {
  skip_on_cran()
  skip_if(.is_windows() && .on_ci(), "Windows on CI")

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
  fs::file_move("README.Rmd", "README.qmd") # special thing quarto
  setup_docs("quarto_website")
  expect_no_error(render_docs(verbose = .on_ci()))

  ### Quarto output changes depending on the version, I don't have a solution for
  ### now.

  ### test
  # expect_snapshot(.readlines("docs/index.html"))
  # expect_snapshot(.readlines("docs/NEWS.html"))
  # expect_snapshot(.readlines("docs/man/hello_base.html"))
  # expect_snapshot(.readlines("docs/man/hello_r6.html"))
  # expect_snapshot(.readlines("docs/vignettes/test.html"))
})


test_that("quarto: autolink", {
  skip_on_cran()
  skip_if(.is_windows() && .on_ci(), "Windows on CI")

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
  fs::file_move("README.Rmd", "README.qmd") # special thing quarto
  setup_docs("quarto_website")
  expect_no_error(render_docs(verbose = .on_ci()))

  tmp <- .readlines("docs/vignettes/test.html")
  expect_true(any(grepl("https://rdrr.io/r/base/library.html", tmp, fixed = TRUE)))
})


# Test failures ------------------------------

test_that("render_docs errors if vignettes fail", {
  create_local_package()
  fs::dir_create("vignettes")
  cat("# Get Started\n```{r}\n1 +\n```\n", file = "vignettes/foo.Rmd")
  setup_docs("docute", path = getwd())
  expect_error(
    render_docs(path = getwd()),
    "some failures when rendering vignettes"
  )
})

test_that("render_docs errors if man fail", {
  create_local_package()
  fs::dir_create("man")
  cat("\\name{hi}\n\\title{hi}\n\\usage{\nhi()\n}\n\\examples{\n1 +\n}\n", file = "man/foo.Rd")
  setup_docs("docute", path = getwd())
  expect_error(
    render_docs(path = getwd()),
    "some failures when rendering man pages"
  )
})
