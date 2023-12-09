test_that(".substitute_altdoc_vars removes github if no url", {
  create_local_package()
  desc::desc_set_urls("https://foobar.com")
  setup_docs("docute")
  render_docs()
  content <- .readlines("docs/index.html")
  expect_false(any(grepl("$ALTDOC_PACKAGE_URL_GITHUB", content, fixed = TRUE)))
})

test_that(".substitute_altdoc_vars removes website if no url", {
  create_local_package()
  desc::desc_set_urls("https://github.com/foo/bar")
  setup_docs("docute")
  render_docs()
  content <- .readlines("docs/index.html")
  expect_false(any(grepl("$ALTDOC_PACKAGE_URL", content, fixed = TRUE)))
})
