test_that("preview_docs: basic errors", {
  create_local_package()
  expect_error(
    preview_docs(),
    "No documentation tool detected"
  )

  setup_docs("docute")
  expect_error(
    preview_docs(),
    "You must render the docs before previewing them"
  )
})
