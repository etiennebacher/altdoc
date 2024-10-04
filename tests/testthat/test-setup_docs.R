test_that("must be a package", {
  create_local_project()
  expect_error(
    setup_docs(tool = "docute", path = getwd()),
    "only works in packages"
  )
})

test_that("setup_docs doesn't automatically overwrite", {
    create_local_package()
    setup_docs(tool = "docute", path = getwd())
    expect_error(
      setup_docs("docsify", path = getwd()),
      "already exists"
    )
})

test_that("setup_docs errors if missing tool", {
    create_local_package()
    expect_error(
      setup_docs(path = getwd()),
      "argument must be \"docsify\", \"docute\""
    )
})

test_that("overwrite=TRUE works: docute", {
    create_local_package()
    setup_docs(tool = "docute", path = getwd())
    cat("Cruft", file = "altdoc/docute.html", append = TRUE)
    txt <- readLines("altdoc/docute.html", warn = FALSE)
    expect_true("Cruft" %in% txt)
    setup_docs(tool = "docute", path = getwd(), overwrite = TRUE)
    txt <- readLines("altdoc/docute.html", warn = FALSE)
    expect_false("Cruft" %in% txt)
})

test_that("overwrite=TRUE works: docsify", {
    create_local_package()
    setup_docs(tool = "docsify", path = getwd())
    cat("Cruft", file = "altdoc/docsify.html", append = TRUE)
    txt <- readLines("altdoc/docsify.html", warn = FALSE)
    expect_true("Cruft" %in% txt)
    setup_docs(tool = "docsify", path = getwd(), overwrite = TRUE)
    txt <- readLines("altdoc/docsify.html", warn = FALSE)
    expect_false("Cruft" %in% txt)
})

test_that("overwrite=TRUE works: mkdocs", {
    skip_if_not(.venv_exists())
    create_local_package()
    setup_docs(tool = "mkdocs", path = getwd())
    cat("Cruft", file = "altdoc/mkdocs.yml", append = TRUE)
    txt <- readLines("altdoc/mkdocs.yml", warn = FALSE)
    expect_true("Cruft" %in% txt)
    setup_docs(tool = "mkdocs", path = getwd(), overwrite = TRUE)
    txt <- readLines("altdoc/mkdocs.yml", warn = FALSE)
    expect_false("Cruft" %in% txt)
})

test_that("quarto: README.qmd", {
  create_local_package()
  expect_false(file.exists("README.qmd"))
  setup_docs("quarto_website", overwrite = TRUE)
  expect_false(file.exists("README.qmd"))
})
