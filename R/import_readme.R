.import_readme <- function(src_dir, tar_dir, tool) {

  # render .Rmd or .qmd file if available
  fn_qmd <- fs::path_join(c(src_dir, "README.qmd"))
  fn_rmd <- fs::path_join(c(src_dir, "README.Rmd"))
  if (fs::file_exists(fn_qmd)) {
    .qmd2md(fn_qmd, src_dir)
  } else if (fs::file_exists(fn_rmd)) {
    .qmd2md(fn_rmd, src_dir)
  }

  src_file <- fs::path_join(c(src_dir, "README.md"))
  if (tool == "quarto_website") {
    tar_file <- fs::path_join(c(tar_dir, "index.md"))
  } else {
    tar_file <- fs::path_join(c(tar_dir, "README.md"))
  }

  # default readme is mandatory for some docs generators
  if (!fs::file_exists(src_file)) {
    writeLines(c("", "Hello world!"), src_file)
  }

  fs::file_copy(src_file, tar_file, overwrite = TRUE)
  .check_md_structure(tar_file)

  # TODO: fix this for Quarto
  if (tool != "quarto_website") {
    .move_img_readme(path = src_dir)
    .replace_img_paths_readme(path = src_dir)
  }

  cli::cli_alert_success("{.file README} imported.")
}


# Copy images/GIF that are in README in 'docs'

.move_img_readme <- function(path = ".") {
  img_paths <- .img_paths_readme(path)
  if (is.null(img_paths)) {
    return(invisible())
  }
  good_path <- .doc_path(path)
  for (assets in c("/README_assets", "/README.markdown_strict_files")) {
    fs::dir_create(paste0(good_path, assets))
    for (i in seq_along(img_paths)) {
      fs::file_copy(
        img_paths[i],
        fs::path_join(c(good_path, assets, trimws(basename(img_paths[i])))),
        overwrite = TRUE
      )
    }
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
    regmatches(
      file_content,
      gregexpr('!\\[[^\\]]*\\]\\((.*?)\\s*("(?:.*[^"])")?\\s*\\)',
        file_content,
        perl = TRUE
      )
    )
  )
  img_path <- img_path[grep("http", img_path, invert = TRUE)]
  img_path <- gsub("!\\[\\]", "", img_path)
  img_path <- gsub("\\(", "", img_path)
  img_path <- gsub("\\)", "", img_path)


  # when double quotes, i.e <img src="path">
  img_path_double_quotes <- unlist(
    regmatches(
      file_content,
      gregexpr('(?<=img src=\\").*?(?=\\")',
        file_content,
        perl = TRUE
      )
    )
  )
  # when single quotes, i.e <img src='path'>
  img_path_single_quotes <- unlist(
    regmatches(
      file_content,
      gregexpr("(?<=img src=\\').*?(?=\\')",
        file_content,
        perl = TRUE
      )
    )
  )

  img_path <- c(img_path, img_path_single_quotes, img_path_double_quotes)
  img_path <- img_path[grep("http", img_path, invert = TRUE)]

  img_path
}
