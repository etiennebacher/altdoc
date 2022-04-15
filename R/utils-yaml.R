# Modify yaml of vignettes: remove HTML formats in output, remove all
# vignette parameters (starting with %\Vignette), and add github_document
# in output formats.

modify_yaml <- function(filename) {

  # Extract yaml from Rmd
  x <- readLines(filename, warn = FALSE)
  yaml_limits <- grep("---", x)[c(1,2)]
  yaml <- x[yaml_limits[1]:yaml_limits[2]]
  new_vignette <- x[-c(yaml_limits[1]:yaml_limits[2])]

  # Save a tmp file (required by yaml::read_yaml)
  tmp <- tempfile()
  writeLines(yaml, tmp, useBytes = TRUE)

  # Get yaml as a list, remove vignette options, remove HTML outputs
  # (but keep pdf if there are some)
  original_yaml <- yaml::read_yaml(tmp)
  if (!is.null(original_yaml$vignette)) {
    original_yaml$vignette <- NULL
  }

  if (length(original_yaml$output) == 1) {
    # the condition below is not the same if the output has options (= is
    # a list) or not (= a character vector)
    has_options <- is.list(original_yaml$output)
    target <- if (has_options) {
      names(original_yaml$output)
    } else {
      original_yaml$output
    }
    if (grepl("html_", target))
      original_yaml$output <- "github_document: default"
  } else if (length(original_yaml$output) > 1) { # if other outputs present (e.g pdf), keep them
    html_outputs <- names(original_yaml$output)
    html_outputs <- grep("html_", html_outputs)
    original_yaml$output[[html_outputs]] <- NULL
    original_yaml$output[["github_document"]] <- "default"

    # the first output must be github document
    original_yaml$output <- rev(original_yaml$output)
  }
  # necessary for some Rmd files
  original_yaml$always_allow_html <- TRUE

  # yaml::as.yaml introduces a line break in yaml title if it's too long
  # so I need to fix it manually by splitting the yaml in two parts
  new_yaml_1 <- yaml::as.yaml(original_yaml$title)
  new_yaml_1 <- paste0("title: ", new_yaml_1)
  new_yaml_1 <- gsub("\\\n", "", new_yaml_1)
  if (length(original_yaml) > 1) {
    new_yaml_2 <- yaml::as.yaml(original_yaml[grep("title", names(original_yaml), invert = TRUE)])
  } else {
    new_yaml_2 <- NULL
  }


  new_yaml <- paste0(new_yaml_1, "\n", new_yaml_2)

  # Finish the new yaml and add it back to the vignette
  if (!grepl("github_document", new_yaml)) {
    new_yaml <- paste0(new_yaml, "output:\n  github_document: default\n")
  }
  new_yaml <- gsub("'github_document: default'\\\n",
                   "\\\n  github_document: default\\\n",
                   new_yaml)
  new_yaml <- gsub("\\\n$", "", new_yaml)
  new_yaml <- c("---", new_yaml, "---\n")

  new_vignette <- c(new_yaml, new_vignette)
  writeLines(new_vignette, filename, useBytes = TRUE)
}


# Find bib files in vignettes, and copy them to docs/articles (+ potential
# relative path)
extract_import_bib <- function(filename) {

  good_path <- doc_path()
  articles_path <- paste0(good_path, "/articles")

  # Extract yaml from Rmd
  x <- readLines(filename, warn = FALSE)
  yaml_limits <- grep("---", x)[c(1,2)]
  yaml <- x[yaml_limits[1]:yaml_limits[2]]

  # Save a tmp file (required by yaml::read_yaml)
  tmp <- tempfile()
  writeLines(yaml, tmp, useBytes = TRUE)

  # Get yaml as a list, remove vignette options, remove HTML outputs
  # (but keep pdf if there are some)
  original_yaml <- yaml::read_yaml(tmp)
  if (is.null(original_yaml$bibliography))
    return(invisible())

  bib <- original_yaml$bibliography

  for (i in seq_along(bib)) {
    dir_create(
      dirname(
        paste0(articles_path, "/", bib[i])
      )
    )
    file_copy(
      paste0("vignettes/", bib[i]),
      paste0(articles_path, "/", bib[i]),
      overwrite = TRUE
    )
  }

}
