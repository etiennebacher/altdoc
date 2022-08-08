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

reformat_md <- function(file, first = FALSE) {

  stopifnot(!is.null(file), is.character(file))


  ### Code partly taken from https://github.com/ropensci/tinkr/blob/main/R/to_md.R
  ### (tinkr is not on CRAN, which is why I take their code)


  md_file <- readLines(file, warn = FALSE)

  md_doc <- xml2::read_xml(commonmark::markdown_xml(md_file))

  headers <- xml2::xml_find_all(md_doc,
                                xpath = './/d1:heading',
                                xml2::xml_ns(md_doc))

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

  stylesheet <- xml2::read_xml(system.file("extdata", "xml2md_gfm.xsl", package = "altdoc"))

  out <- xslt::xml_xslt(md_doc, stylesheet = stylesheet)
  writeLines(out, file)


}

# Copy images/GIF that are in README in 'docs'

move_img_readme <- function(path = ".") {

  img_paths <- img_paths_readme(path = path)
  if (is.null(img_paths)) return(invisible())

  good_path <- doc_path(path = path)
  fs::dir_create(paste0(good_path, "/README_assets"))
  for (i in seq_along(img_paths)) {
    fs::file_copy(
      img_paths[i],
      paste0(good_path, "/README_assets/", trimws(basename(img_paths[i]))),
      overwrite = T
    )
  }

}

# Replace image paths in README

replace_img_paths_readme <- function(path = ".") {

  good_path <- doc_path(path = path)
  file_content <- readLines(paste0(good_path, "/README.md"), warn = FALSE)
  img_paths <- img_paths_readme(path = path)

  # generate the new paths
  new_paths <- unlist(lapply(img_paths, function(x) {

    # Thanks stackoverflow: https://stackoverflow.com/questions/49499703/in-r-how-to-remove-everything-before-the-last-slash
    trimws(basename(x))
  }))

  # replace the old paths by the new ones
  for (i in seq_along(img_paths)) {
    file_content <- gsub(img_paths[i], paste0("README_assets/", new_paths[i]), file_content)
  }

  writeLines(file_content, paste0(good_path, "/README.md"))

}

# Get the paths of images/GIF in README

img_paths_readme <- function(path = ".") {

  good_path <- doc_path(path = path)
  file_content <- paste(readLines(paste0(good_path, "/README.md"), warn = FALSE), collapse = "\n")

  # regex adapted from https://stackoverflow.com/a/44227600/11598948
  # (second one)
  img_path <- unlist(
    regmatches(file_content,
               gregexpr('!\\[[^\\]]*\\]\\((.*?)\\s*("(?:.*[^"])")?\\s*\\)',
                        file_content, perl = TRUE)
    )
  )
  img_path <- img_path[which(!grepl("http", img_path))]
  img_path <- gsub("!\\[\\]", "", img_path)
  img_path <- gsub("\\(", "", img_path)
  img_path <- gsub("\\)", "", img_path)


  # when double quotes, i.e <img src="path">
  img_path_double_quotes <- unlist(
    regmatches(file_content,
               gregexpr('(?<=img src=\\").*?(?=\\")',
                        file_content, perl = TRUE)
    )
  )
  # when single quotes, i.e <img src='path'>
  img_path_single_quotes <- unlist(
    regmatches(file_content,
               gregexpr("(?<=img src=\\').*?(?=\\')",
                        file_content, perl = TRUE)
    )
  )

  img_path <- c(img_path, img_path_single_quotes, img_path_double_quotes)
  img_path <- img_path[which(!grepl("http", img_path))]

  return(img_path)

}


# Find figures path in vignettes, copy the figures to "articles/figures"
replace_figures_rmd <- function(path = ".") {

  vignettes_path <- fs::path_abs("vignettes", start = path)

  ### First, extract paths of figures and copy figures to "articles/figures"
  if (!file.exists(vignettes_path) |
      folder_is_empty(vignettes_path)) {
    return(invisible())
  }
  good_path <- doc_path(path = path)
  articles_path <- paste0(good_path, "/articles")

  if (!fs::dir_exists(articles_path)) {
    fs::dir_create(articles_path)
  }
  if (!fs::dir_exists(paste0(articles_path, "/figures"))) {
    fs::dir_create(paste0(articles_path, "/figures"))
  }

  vignettes <- list.files(vignettes_path, pattern = ".Rmd$")

  for (i in seq_along(vignettes)) {

    file_content <- paste(readLines(paste0(vignettes_path, "/", vignettes[i]), warn = FALSE), collapse = "\n")

    # regex: https://gist.github.com/ttscoff/dbf4737b04e1635e1d20
    x <- unlist(regmatches(
      file_content,
      gregexpr("(?:\\(|:\\s+)(?!http)([^\\s]+\\.(?:jpe?g|gif|png|svg|pdf))", file_content, perl = TRUE)
    ))
    x <- gsub("\"", "", x)
    x <- gsub(":| ", "", x)
    x <- gsub("!", "", x)
    x <- gsub("\\(|\\)|\\[|\\]", "", x)
    x <- gsub("\\.\\.", "", x)

    new_file_content <- file_content

    for (j in seq_along(x)) {

      new_file_content <- gsub(
        x[j],
        paste0("figures/", x[j]),
        new_file_content
      )

      if (substr(x[j], 1, 1) == "/") {
        x[j] <- substr(x[j], 2, nchar(x[j]))
      }
      if (!startsWith(x[j], "vignettes")) {
        x[j] <- paste0(vignettes_path, "/", x[j])
      }

    }
    origin_fig <- x
    destination_fig <- paste0(articles_path, "/figures/", trimws(basename(origin_fig)))
    writeLines(new_file_content, paste0(articles_path, "/", vignettes[i]))

    if (length(origin_fig) == 0) next

    for (j in seq_along(origin_fig)) {
      if (fs::file_exists(origin_fig[j])) {
        fs::file_copy(origin_fig[j], destination_fig[j], overwrite = TRUE)
      }
    }
  }

}


# Change figure paths in articles
#
# Rmd files in "articles" need to have img paths starting with
# "figures/" in order to compile.
# However, docute and docsify need the paths in the .md files to
# start with "articles/figures/" so I need to add "articles/"
# just before "figures/" in the img paths, *after* compilation.

fix_rmd_figures_path <- function(path = ".") {

  good_path <- doc_path(path = path)

  if (!fs::dir_exists(paste0(good_path, "/articles/figures"))) {
    return(invisible())
  }

  articles <- list.files(
    paste0(good_path, "/articles"),
    full.names = TRUE,
    pattern = "\\.md$"
  )

  warn <- FALSE
  for (i in articles) {

    orig <- readLines(i, warn = FALSE)
    if (doc_type() %in% c("docsify", "docute")) {
      mod <- gsub('"figures/', '"articles/figures/', orig)
      mod <- gsub("'figures/", "'articles/figures/", mod)
      writeLines(mod, i)
    }
    if (!warn && any(grepl("<img", orig))) {
      warn <- TRUE
    }
  }

  if (doc_type() == "mkdocs" && warn) {
    cli::cli_alert_warning("HTML image tag {.code <img>} was detected in at least one article.")
    cli::cli_alert_warning("Mkdocs recommends using Markdown syntax instead of HTML tags. Some images might not be displayed in the articles.")
  }

}
