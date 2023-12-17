test_that("must be a package", {
  create_local_project()
  expect_error(
    setup_docs(tool = "docute"),
    "only works in packages"
  )
})

test_that("setup_docs doesn't automatically overwrite", {
    create_local_package()
    setup_docs(tool = "docute")
    expect_error(
      setup_docs("docsify"),
      "already exists"
    )
})

test_that("setup_docs errors if missing tool", {
    create_local_package()
    expect_error(
      setup_docs(),
      "argument must be \"docsify\", \"docute\""
    )
})

test_that("overwrite=TRUE works: docute", {
    create_local_package()
    setup_docs(tool = "docute")
    cat("Cruft", file = "altdoc/docute.html", append = TRUE)
    txt <- readLines("altdoc/docute.html", warn = FALSE)
    expect_true("Cruft" %in% txt)
    setup_docs(tool = "docute", overwrite = TRUE)
    txt <- readLines("altdoc/docute.html", warn = FALSE)
    expect_false("Cruft" %in% txt)
})

test_that("overwrite=TRUE works: docsify", {
    create_local_package()
    setup_docs(tool = "docsify")
    cat("Cruft", file = "altdoc/docsify.html", append = TRUE)
    txt <- readLines("altdoc/docsify.html", warn = FALSE)
    expect_true("Cruft" %in% txt)
    setup_docs(tool = "docsify", overwrite = TRUE)
    txt <- readLines("altdoc/docsify.html", warn = FALSE)
    expect_false("Cruft" %in% txt)
})

test_that("overwrite=TRUE works: mkdocs", {
    skip_if_not(.venv_exists())
    create_local_package()
    setup_docs(tool = "mkdocs")
    cat("Cruft", file = "altdoc/mkdocs.yml", append = TRUE)
    txt <- readLines("altdoc/mkdocs.yml", warn = FALSE)
    expect_true("Cruft" %in% txt)
    setup_docs(tool = "mkdocs", overwrite = TRUE)
    txt <- readLines("altdoc/mkdocs.yml", warn = FALSE)
    expect_false("Cruft" %in% txt)
})
