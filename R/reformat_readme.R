reformat_readme <- function() {

  y <- readLines('docs/README.md')

  # Check if there are several h1 (need to exclude # in code)
  z <- y
  delim <- which(z == "```")
  while (length(delim) > 0 && delim %% 2 == 0) {
    start <- delim[1]+1
    end <- delim[2]-1
    code <- z[start:end]
    z <- gsub(code, "", z)
    delim <- delim[-c(1, 2)]
  }

  # If several h1, need to transform h1 in h2 (except title), and h2
  # in h3
  if (length(which(grepl("^# ", z) == TRUE)) > 1) {

    y <- gsub("^## ", "### ", y)
    y <- gsub("^# ", "## ", y)

    # Remove # added earlier for package title
    y <- gsub(paste("^##", pkg_name()), paste("#", pkg_name()), y)
    y[1] <- gsub("^##", "#", y[1])

    # Find code chunks, extract them, remove the # added earlier,
    # and reinsert them
    delim <- which(y == "```")
    while (length(delim) > 0 && delim %% 2 == 0) {
      start <- delim[1]+1
      end <- delim[2]-1
      code <- y[start:end]
      code <- gsub("##", "#", code)
      y[start:end] <- code
      delim <- delim[-c(1, 2)]
    }

  }

  writeLines(y, "docs/README.md")

}

