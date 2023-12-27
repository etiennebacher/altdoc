test_that(".setup_github_actions cannot overwrite", {
  create_local_package()
  setup_docs("docute")
  fs::dir_create(".github/workflows")
  fs::file_create(".github/workflows/altdoc.yaml")
  expect_error(
    setup_github_actions(),
    "already exists"
  )
})

test_that(".setup_github_actions works if not mkdocs", {
  create_local_package()
  setup_docs("docute")
  setup_github_actions()
  expect_true(fs::file_exists(".github/workflows/altdoc.yaml"))
  content <- .readlines(".github/workflows/altdoc.yaml")
  expect_false(any(grepl("$ALTDOC_MKDOCS_START", content, fixed = TRUE)))
  expect_false(any(grepl("install mkdocs", content, fixed = TRUE)))
})

test_that(".setup_github_actions works if mkdocs", {
  skip_if_not(.venv_exists())
  create_local_package()
  setup_docs("mkdocs")
  setup_github_actions()
  expect_true(fs::file_exists(".github/workflows/altdoc.yaml"))
  content <- .readlines(".github/workflows/altdoc.yaml")
  expect_false(any(grepl("$ALTDOC_MKDOCS_START", content, fixed = TRUE)))
  expect_true(any(grepl("install mkdocs", content, fixed = TRUE)))
})
