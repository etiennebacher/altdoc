y <- readLines('test.md')
y

# Add an # everywhere
y <- gsub("^## ", "### ", y)
y <- gsub("^# ", "## ", y)
y


# Find code chunks, extract them, remove the # added earlier, and reinsert them
delim <- which(y == "```")

while (length(delim) > 0 && delim %% 2 == 0) {
  start <- delim[1]+1
  end <- delim[2]-1
  code <- y[start:end]
  code <- gsub("##", "#", code)
  y[start:end] <- code
  delim <- delim[-c(1, 2)]
}

y

writeLines(y, "test2.md")
