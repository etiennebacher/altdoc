#' @title Reformat Markdown files
#'
#' @param file Markdown file to reformat
#' @param first Should the first title also be reformatted? Default is `FALSE`.
#'
#' @details
#'
#' To use Docute or Docsify, the format of Markdown files has to follow a precise
#' structure. There must be at most one main section (starting with '#')
#' but there can be as many subsections and subsubsections as you want.
#'
#' If you saw a message saying that \code{README.md} was slightly modified, it
#' is because the README didn't follow these rules. There were probably several
#' main sections, which messed up Docute/Docsify documentation. Therefore,
#' \code{altdoc} automatically added a '#' to all sections and subsections,
#' except the first one, which is usually the title of the package.
#'
#' For example, if your README looked like this:
#'
#' ```
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
#' ```
#'
#' It will now look like that:
#'
#' ```
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
#' ```
#'
#' Note that the main structure is preserved: "Stable version" and "Dev
#'  version" are still subsections of "Installation".
#'
#' Also, if your README includes R comments in code chunks, these will not
#' be modified.
#'
#' @return The original Markdown file, which was modified like the example above.
#' @noRd

.reformat_md <- function(file, first = FALSE) {

  stopifnot(!is.null(file), is.character(file))

  md_doc <- tinkr::to_xml(file)

  headers <- md_doc$body
  headers <- xml2::xml_find_all(
    headers,
    xpath = './/d1:heading',
    xml2::xml_ns(headers)
  )

  levels <- as.numeric(xml2::xml_attr(headers, "level"))

  if (length(levels[levels == 1]) <= 1) return(invisible())

  for (i in rev(unique(levels))) { # start by lowest level
    to_change <- which(xml2::xml_attr(headers, "level") == i)
    for (j in seq_along(to_change)) {
      k <- to_change[j]
      if (k == 1 & isFALSE(first)) next
      xml2::xml_set_attr(headers[k], "level", i + 1)
    }
  }
  tinkr::to_md(md_doc, path = file)

  # 4 spaces for nested lists (can't find a way to fix this in XML)
  doc <- readLines(file, warn = FALSE)
  new_doc <- gsub("^  (\\*|-)", "    \\1", doc)
  cat(paste(new_doc, collapse = "\n"), file = file)
}
