for (tool in c("docute", "docsify", "mkdocs")) {
  test_that(sprintf("render_docs works in parallel: %s", tool), {
    skip_if(tool == "mkdocs" && !.venv_exists())
    create_local_package()
    setup_docs(tool = tool, path = getwd())
    usethis::use_readme_md(open = FALSE)
    expect_no_error(render_docs(path = getwd(), parallel = TRUE))
  })
}
