test_docute <- function() {
  devtools::load_all()
  fs::dir_delete("docs")
  use_docute()
  preview()
}

test_docsify <- function() {
  devtools::load_all()
  fs::dir_delete("docs")
  use_docsify()
  preview()
}
