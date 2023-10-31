# Copy images/GIF that are in README in 'docs'

.move_img_readme <- function(path = ".") {
  img_paths <- .img_paths_readme(path)
  if (is.null(img_paths)) return(invisible())

  good_path <- .doc_path(path)
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

.replace_img_paths_readme <- function(path = ".") {
  good_path <- .doc_path(path)
  file_content <- .readlines(paste0(good_path, "/README.md"))
  img_paths <- .img_paths_readme(path)

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

.img_paths_readme <- function(path = ".") {

  good_path <- .doc_path(path)
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
.replace_figures_rmd <- function(path = ".") {
  vignettes_path <- fs::path_abs("vignettes", start = path)

  # Extract paths of figures and copy figures to "articles/figures"
  if (!file.exists(vignettes_path) |
      altdoc:::.folder_is_empty(vignettes_path)) {
    return(invisible())
  }
  good_path <- altdoc:::.doc_path(path)
  articles_path <- paste0(good_path, "/articles/")

  if (!fs::dir_exists(articles_path)) {
    fs::dir_create(articles_path)
  }
  if (!fs::dir_exists(paste0(articles_path, "figures"))) {
    fs::dir_create(paste0(articles_path, "figures"))
  }

  vignettes <- list.files(vignettes_path, pattern = ".Rmd$")

  # Move images generated through code
  vignettes_folders <- gsub(".Rmd", "_files", vignettes)
  vignettes_folders <- paste0(articles_path, vignettes_folders, "/figure-gfm")
  fig_path <- gsub("articles/", "articles/figures/", vignettes_folders)

  lapply(seq_along(vignettes_folders), function(x) {
    if (dir.exists(vignettes_folders[x])) {
      fs::dir_copy(vignettes_folders[x], fig_path[x])
    }
  })

  vignettes_md <- list.files(articles_path, pattern = ".md$", full.names = TRUE)

  # Edit vignettes to update figure URLs
  for (y in vignettes_md) {
    tx  <- readLines(y)
    tx <- gsub('docs/articles/', 'articles/figures/', tx, fixed = TRUE)
    writeLines(tx, con = y)
  }

}
