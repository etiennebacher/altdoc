test_that(paste("overwrite=TRUE works:", "docute"), {
    create_local_package()
    setup_docs(tool = "docute", path = getwd())
    cat("Cruft", file = "altdoc/docute.html", append = TRUE)
    txt <- readLines("altdoc/docute.html", warn = FALSE)
    expect_true("Cruft" %in% txt)
    setup_docs(tool = "docute", path = getwd(), overwrite = TRUE)
    txt <- readLines("altdoc/docute.html", warn = FALSE)
    expect_false("Cruft" %in% txt)
})

test_that(paste("overwrite=TRUE works:", "docsify"), {
    create_local_package()
    setup_docs(tool = "docsify", path = getwd())
    cat("Cruft", file = "altdoc/docsify.html", append = TRUE)
    txt <- readLines("altdoc/docsify.html", warn = FALSE)
    expect_true("Cruft" %in% txt)
    setup_docs(tool = "docsify", path = getwd(), overwrite = TRUE)
    txt <- readLines("altdoc/docsify.html", warn = FALSE)
    expect_false("Cruft" %in% txt)
})



test_that(paste("overwrite=TRUE works:", "mkdocs"), {
    skip_if_not(.is_mkdocs())
    create_local_package()
    setup_docs(tool = "mkdocs", path = getwd())
    cat("Cruft", file = "altdoc/mkdocs.yml", append = TRUE)
    txt <- readLines("altdoc/mkdocs.yml", warn = FALSE)
    expect_true("Cruft" %in% txt)
    setup_docs(tool = "mkdocs", path = getwd(), overwrite = TRUE)
    txt <- readLines("altdoc/mkdocs.yml", warn = FALSE)
    expect_false("Cruft" %in% txt)
})
