#' @title Reformat the README
#'
#' @details
#'
#' To use Docute or Docsify, the format of Markdown files has to follow a precise
#' structure. There must be at most one main section (starting with '#')
#' but there can be as many subsections and subsubsections as you want.
#'
#' If you saw a message saying that \code{README.md} was slightly modified, it
#' is because the README didn't follow these rules. There were probably several
#' main sections, which messed up with Docute organization. Therefore,
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

reformat_md <- function(file) {

  stopifnot(!is.null(file), is.character(file))

  y <- readLines(file, warn = FALSE)

  # Check if there are several h1 (need to exclude code first)
  z <- y
  delim <- which(grepl("```", z))
  while (length(delim) > 0 && length(delim) %% 2 == 0) {
    start <- delim[1]+1
    end <- delim[2]-1
    z[c(start:end)] <- ""
    delim <- delim[-c(1, 2)]
  }

  # If several h1, need to transform h1 in h2 (except title), and h2
  # in h3
  if (length(which(grepl("^# ", z) == TRUE)) > 1) {

    y <- gsub("^## ", "### ", y)
    y <- gsub("^# ", "## ", y)

    # Remove # added earlier for package title
    y <- gsub(paste("^##", pkg_name()), paste("#", pkg_name()), y)
    if (file == "docs/README.md") {
      y[1] <- gsub("^##", "#", y[1])
    }

    # Find code chunks, extract them, remove the # added earlier,
    # and reinsert them
    delim <- which(grepl("```", y))
    while (length(delim) > 0 && length(delim) %% 2 == 0) {
      start <- delim[1]+1
      end <- delim[2]-1
      code <- y[start:end]
      code <- gsub("##", "#", code)
      y[start:end] <- code
      delim <- delim[-c(1, 2)]
    }

    if (file == "docs/README.md") {
      message_info(sprintf("'%s' had to be slightly modified. Get more info
                           with `?altdoc:::reformat_md`.", file))
    }

  }

  writeLines(y, file)

}

#' Copy images/GIF that are in README in 'docs'

move_img_readme <- function() {

  img_paths <- img_paths_readme()

  for (i in seq_along(img_paths)) {
    fs::file_copy(
      img_paths[i],
      paste0("docs/", trimws(basename(img_paths[i]))),
      overwrite = T
    )
  }

}

#' Replace image paths in README

replace_img_paths_readme <- function() {

  file_content <- readLines("docs/README.md", warn = FALSE)
  img_paths <- img_paths_readme()

  # generate the new paths
  new_paths <- unlist(lapply(img_paths, function(x) {

    # Thanks stackoverflow: https://stackoverflow.com/questions/49499703/in-r-how-to-remove-everything-before-the-last-slash
    trimws(basename(x))
  }))

  # replace the old paths by the new ones
  for (i in seq_along(img_paths)) {
    file_content <- gsub(img_paths[i], new_paths[i], file_content)
  }

  writeLines(file_content, "docs/README.md")

}

#' Get the paths of images/GIF in README

img_paths_readme <- function() {

  file_content <- paste(readLines("docs/README.md", warn = FALSE), collapse = "\n")

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
