library(testthat)
library(altdoc)

test_that("quarto: freeze skips man pages when unchanged", {
    skip_on_cran()
    skip_if(!.quarto_is_installed())

    ### setup: create a temp package
    create_local_package()
    fs::dir_create("man")
    cat(
        "\\name{hi}\n\\title{hi}\n\\usage{\nhi()\n}\n\\description{hi}\n",
        file = "man/hi.Rd"
    )
    cat(
      "\\name{ho}\n\\title{ho}\n\\usage{\nho()\n}\n\\description{ho}\n",
      file = "man/ho.Rd"
    )

    setup_docs("quarto_website")

    # First run
    render_docs(freeze = TRUE, verbose = FALSE)

    expect_true(fs::file_exists("_quarto/man/ho.qmd"))
    expect_true(fs::file_exists("docs/man/ho.html"))
    expect_true(fs::file_exists("altdoc/freeze.rds"))

    mtime1 <- fs::file_info("_quarto/man/hi.qmd")$modification_time

    # Delete one of the .Rd files to check that cleanup works
    fs::file_delete("man/ho.Rd")

    # Second run
    Sys.sleep(1.1) # Ensure time difference
    out <- capture_messages(render_docs(freeze = TRUE, verbose = FALSE))

    # Check that stale files are removed
    expect_false(fs::file_exists("_quarto/man/ho.qmd"))
    expect_false(fs::file_exists("docs/man/ho.html"))

    # Check that re-generation was skipped
    mtime2 <- fs::file_info("_quarto/man/hi.qmd")$modification_time
    expect_equal(mtime1, mtime2)

    expect_match(paste(out, collapse = "\n"), "1 .Rd files skipped because they didn't change")
})
