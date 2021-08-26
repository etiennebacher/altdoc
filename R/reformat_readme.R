#' @title Reformat the README
#'
#' @details
#'
#' To use Docute, the format of Markdown files has to follow a precise
#' structure. There must be at most one main section (starting with '#')
#' but there can be as many subsections and subsubsections as you want.
#'
#' If you saw a message saying that \code{README.md} was slightly modified, it
#' is because the README didn't follow these rules. There probably was several
#' main sections, which messed up with Docute organization. Therefore,
#' \code{altdoc} automatically added a '#' to all sections and subsections,
#' except the first one, which is usually the title of the package.
#'
#' For example, if your README looked like this:
#'
#' \preformatted{
#' # Package
#'
#' # Installation
#'
#' ## Stable version
#'
#' ## Dev version
#'
#' Hello
#'
#' # Demo
#'
#' Hello again
#' }
#'
#' It will now look like that:
#'
#' \preformatted{
#' # Package
#'
#' ## Installation
#'
#' ### Stable version
#'
#' ### Dev version
#'
#' Hello
#'
#' ## Demo
#'
#' Hello again
#' }
#'
#' Note that the main structure is preserved: "Stable version" and "Dev
#'  version" are still subsections of "Installation".
#'
#' Also, if your README includes R comments in code chunks, these will not
#' be modified.

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

    message_info("'README.md' had to be slightly modified.
    Get more info with `?altdoc:::reformat_readme`.")

  }

  writeLines(y, "docs/README.md")

}

