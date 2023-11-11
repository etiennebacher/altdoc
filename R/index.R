# Create index.html for docute and docsify ------------------

.create_index <- function(x, path = ".") {
  index <- htmltools::htmlTemplate(
    system.file(paste0(x, "/index.html"), package = "altdoc"),
    title = .pkg_name(path),
    footer = sprintf(
      "<hr/><a href='%s'> <code>%s</code> v. %s </a> | Documentation made with <a href='https://github.com/etiennebacher/altdoc'> <code>altdoc</code> v. %s</a>",
      .gh_url(path), .pkg_name(path), .pkg_version(path),
      .altdoc_version()
    ),
    github_link = .gh_url(path)
  )

  # regex stuff to correct footer
  index <- as.character(index)
  index <- gsub("&lt;", "<", index)
  index <- gsub("&gt;", ">", index)
  index <- gsub("\\r\\n", "\\\n", index)

  writeLines(index, fs::path_abs("docs/index.html", start = path))
}

