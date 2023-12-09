test_that("comparing hashes works", {
  source_file <- tempfile()
  fs::file_copy(test_path("examples/examples-man/between.Rd"), source_file)
  hashes <- digest::digest(.readlines(source_file))
  names(hashes) <- source_file
  expect_true(.read_freeze(source_file, source_file, hashes))

  other_source_file <- test_path("examples/examples-man/between.md")
  expect_false(.read_freeze(other_source_file, other_source_file, hashes))

  # modified file doesn't have the same hash
  mod <- c(.readlines(source_file), "abc")
  cat(mod, file = source_file)
  expect_false(.read_freeze(source_file, source_file, hashes))
})

test_that(".read_freeze is FALSE if files don't exist", {
  source_file <- tempfile()
  fs::file_copy(test_path("examples/examples-man/between.Rd"), source_file)
  hashes <- digest::digest(.readlines(source_file))
  names(hashes) <- source_file
  expect_false(.read_freeze("foobar", "foobar", hashes))
})
