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

reformat_md <- function(file, first = FALSE) {

  stopifnot(!is.null(file), is.character(file))

  md_doc <- tinkr::to_xml(file)

  headers <- md_doc$body
  headers <- xml2::xml_find_all(headers,
                                xpath = './/d1:heading',
                                xml2::xml_ns(headers))

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

}

# Copy images/GIF that are in README in 'docs'

move_img_readme <- function() {

  img_paths <- img_paths_readme()
  if (is.null(img_paths)) return(invisible())

  good_path <- doc_path()
  dir_create(paste0(good_path, "/README_assets"))
  for (i in seq_along(img_paths)) {
    file_copy(
      img_paths[i],
      paste0(good_path, "/README_assets/", trimws(basename(img_paths[i]))),
      overwrite = T
    )
  }

}

# Replace image paths in README

replace_img_paths_readme <- function() {

  good_path <- doc_path()
  file_content <- readLines(paste0(good_path, "/README.md"), warn = FALSE)
  img_paths <- img_paths_readme()

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

img_paths_readme <- function() {

  good_path <- doc_path()
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
replace_figures_rmd <- function() {

  ### First, extract paths of figures and copy figures to "articles/figures"
  if (!file.exists("vignettes") | folder_is_empty("vignettes")) {
    return(invisible())
  }
  good_path <- doc_path()
  figures_path <- paste0(good_path, "/articles/figures")
  if (!dir_exists(figures_path)) {
    dir_create(figures_path)
  }
  vignettes <- list.files("vignettes", pattern = ".Rmd$")

  for (i in seq_along(vignettes)) {

    file_content <- paste(readLines(paste0("vignettes/", vignettes[i]), warn = FALSE), collapse = "\n")

    x <- unlist(regmatches(
      file_content,
      gregexpr("(?<=\\().*?(?=\\))", file_content, perl = TRUE)
    ))
    x <- x[grepl("/", x)]
    x <- x[!grepl("http", x)]
    x <- gsub("\"", "", x)
    x <- gsub("\\.\\.", "", x)
    for (i in seq_along(x)) {
      if (substr(x[i], 1, 1) == "/") {
        x[i] <- substr(x[i], 2, nchar(x[i]))
      }
    }
    origin_fig <- x
    destination_fig <- paste0(figures_path, "/", trimws(basename(origin_fig)))

    if (length(origin_fig) == 0) next

    for (i in seq_along(origin_fig)) {
      if (file_exists(origin_fig[i])) {
        file_copy(origin_fig[i], destination_fig[i], overwrite = TRUE)
      }
    }
  }

}
