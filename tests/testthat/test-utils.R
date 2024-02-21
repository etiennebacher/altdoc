test_that(".folder_is_empty() works", {
  create_local_package()
  fs::dir_create("docs")
  expect_true(.folder_is_empty("docs"))

  fs::file_create("docs/test.md")
  expect_false(.folder_is_empty("docs"))
})

test_that(".pkg_name() works", {
  create_local_package()
  expect_true(is.character(.pkg_name(getwd())))
  expect_true(nchar(.pkg_name(getwd())) > 0)
})

test_that(".pkg_version() works", {
  create_local_package()
  expect_true(is.character(.pkg_version(".")))
  expect_true(nchar(.pkg_version(".")) > 0)
})

test_that(".parse_news works", {
  skip_if_not_installed("desc")
  create_local_package()
  desc::desc_set_urls("https://github.com/etiennebacher/altdoc")
  input <- "# 1.1.0\n\n* thanks @foo-bar for their contribution (#111)\n\n* thanks @foo2- for their contribution (#11)\n\n* due to issue in another repo (pola-rs/polars#112)\n\n* thanks @JohnDoe, @JaneDoe"
  cat(input, file = "NEWS.md")
  .parse_news(".", "NEWS.md")
  parsed <- paste(.readlines("NEWS.md"), collapse = "")

  should_be_found <- c(
    "[@foo-bar](https://github.com/foo-bar)",
    "[#111](https://github.com/etiennebacher/altdoc/issues/111)",
    "[@foo2-](https://github.com/foo2-)",
    "[#11](https://github.com/etiennebacher/altdoc/issues/11)",
    "[@JohnDoe](https://github.com/JohnDoe), [@JaneDoe](https://github.com/JaneDoe)"
  )

  expect_true(
    all(sapply(should_be_found, grepl, x = parsed, fixed = TRUE))
  )
})

test_that(".which_license works", {
  create_local_package()
  fs::file_create("LICENSE.md")
  expect_equal(.which_license(), "LICENSE.md")
  fs::file_delete("LICENSE.md")
  fs::file_create("LICENCE.md")
  expect_equal(.which_license(), "LICENCE.md")
  fs::file_delete("LICENCE.md")
  expect_null(.which_license())
})

test_that(".find_head_branch works if no git", {
  create_local_package()
  expect_null(.find_head_branch())
})
