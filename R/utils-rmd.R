# Copy images/GIF that are in README in 'docs'

move_img_readme <- function(path = ".") {
  img_paths <- img_paths_readme(path)
  if (is.null(img_paths)) return(invisible())

  good_path <- doc_path(path)
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
  good_path <- doc_path(path)
  file_content <- .readlines(paste0(good_path, "/README.md"))
  img_paths <- img_paths_readme(path)

  # generate the new paths
  new_paths <- unlist(lapply(img_paths, function(x) {
    # https://stackoverflow.com/questions/49499703/in-r-how-to-remove-everything-before-the-last-slash
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

  good_path <- doc_path(path)
  file_content <- paste(.readlines(paste0(good_path, "/README.md")), collapse = "\n")

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

  img_path
}


# Find figures path in vignettes, copy the figures to "articles/figures"
replace_figures_rmd <- function(path = ".") {
  vignettes_path <- fs::path_abs("vignettes", start = path)

  # Extract paths of figures and copy figures to "articles/figures"
  if (!file.exists(vignettes_path) |
      folder_is_empty(vignettes_path)) {
    return(invisible())
  }
  good_path <- doc_path(path)
  articles_path <- paste0(good_path, "/articles")

  if (!fs::dir_exists(articles_path)) {
    fs::dir_create(articles_path)
  }
  if (!fs::dir_exists(paste0(articles_path, "/figures"))) {
    fs::dir_create(paste0(articles_path, "/figures"))
  }

  vignettes <- list.files(vignettes_path, pattern = ".Rmd$")

  for (i in seq_along(vignettes)) {

    file_content <- paste(.readlines(paste0(vignettes_path, "/", vignettes[i])), collapse = "\n")

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

  good_path <- doc_path(path)

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

    orig <- .readlines(i)
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
