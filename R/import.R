# Import files: README, license, news, CoC ------------------

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


.import_citation <- function(src_dir, tar_dir) {
  src_file <- fs::path_join(c(src_dir, "CITATION.md"))
  tar_file <- fs::path_join(c(tar_dir, "CITATION.md"))

  # user-supplied
  if (fs::file_exists(src_file)) {
    fs::file_copy(src_file, tar_file, overwrite = TRUE)

    # auto-generated
  } else {
    cite <- suppressWarnings(
      tryCatch(
        {
          name <- desc::desc_get_field("Package")
          cite <- utils::capture.output(print(utils::citation(name)))
          c("# Citation", "", "```verbatim", cite, "```")
        },
        error = function(e) NULL)
    )
    if (!is.null(cite)) {
      writeLines(cite, tar_file)
    }
  }
}


.import_coc <- function(src_dir, tar_dir, tool) {
  src_file <- fs::path_join(c(src_dir, "CODE_OF_CONDUCT.md"))
  tar_file <- fs::path_join(c(tar_dir, "CODE_OF_CONDUCT.md"))
  if (fs::file_exists(src_file)) {
    if (!fs::file_exists(tar_file)) {
      cli::cli_alert_success("{.file CODE_OF_CONDUCT} imported for the first time.")
    }
    fs::file_copy(src_file, tar_file, overwrite = TRUE)
    cli::cli_alert_success("{.file CODE_OF_CONDUCT} imported.")
  }
}


.import_license <- function(src_dir, tar_dir, tool) {
  src_file <- .which_license(src_dir)
  tar1 <- fs::path_join(c(tar_dir, "LICENSE.md"))
  tar2 <- fs::path_join(c(tar_dir, "LICENCE.md"))
  if (!is.null(src_file) && fs::file_exists(src_file)) {
    if (!fs::file_exists(tar1) && !fs::file_exists(tar2)) {
      cli::cli_alert_success("{.file LICENSE} imported for the first time.")
    }
    fs::file_copy(src_file, tar_dir, overwrite = TRUE)
    cli::cli_alert_success("{.file LICENSE} imported.")
  }
}


.import_news_changelog <- function(src_dir, tar_dir, name = "NEWS") {
  src <- c(
    "NEWS.md", "NEWS.txt", "NEWS", "NEWS.Rd",
    "inst/NEWS.md", "inst/NEWS.txt", "inst/NEWS", "inst/NEWS.Rd"
  )
  src <- gsub("NEWS", name, src, fixed = TRUE)
  src <- sapply(src, function(x) fs::path_join(c(src_dir, x)))
  src <- Filter(fs::file_exists, src)

  # no news to import
  if (length(src) == 0) {
    return(invisible())
  # priority hard-coded by the order of the vector above
  } else {
    src <- src[1]
  }

  tar <- fs::path_join(c(tar_dir, paste0(name, ".md")))
  first <- !fs::file_exists(tar)
  if (first) {
    cli::cli_alert_success("{.file {name}} imported for the first time.")
  }

  # .Rd -> .md
  if (fs::path_ext(src) == "Rd") {
    .rd2qmd(src, tar_dir)
    .qmd2md(fs::path_join(c(tar_dir, paste0(name, ".qmd"))), tar_dir)
    # the files I tried were too deeply nested
    x <- .readlines(tar)
    if (!any(grepl("^# ", x))) {
      writeLines(gsub("^##", "#", x), tar)
    }

  # all other formats only require a copy
  } else {
    fs::file_copy(src, tar, overwrite = TRUE)
  }

  # insert links, etc.
  .parse_news(path = src_dir, news_path = tar)

  if (!first) {
    cli::cli_alert_success("{.file {name}} imported.")
  }
}


# Autolink news, PR, and people in NEWS
.parse_news <- function(path, news_path) {
  if (!fs::file_exists(news_path)) {
    return(invisible())
  }

  orig_news <- .readlines(news_path)
  orig_news <- paste(orig_news, collapse = "\n")
  new_news <- orig_news

  ### Issues

  issues_pr <- regmatches(orig_news, gregexpr("#\\d+", orig_news))[[1]]
  if (length(issues_pr) > 0) {
    issues_pr_link <- paste0(.gh_url(path), "/issues/", gsub("#", "", issues_pr))

    issues_pr_out <- data.frame(
      in_text = issues_pr,
      replacement = paste0("[", issues_pr, "](", issues_pr_link, ")"),
      nchar = nchar(issues_pr)
    ) |>
      unique()

    # need to go in decreasing order of characters so that we don't insert the
    # link for #78 in "#783" for instance

    issues_pr_out <- issues_pr_out[order(issues_pr_out$nchar, decreasing = TRUE), ]

    for (i in seq_len(nrow(issues_pr_out))) {
      new_news <- gsub(paste0(issues_pr_out[i, "in_text"], "(?![0-9])"),
        issues_pr_out[i, "replacement"],
        new_news,
        perl = TRUE
      )
    }
  }


  ### People

  people <- regmatches(orig_news, gregexpr("(^|[^@\\w])@(\\w{1,50})\\b", orig_news))[[1]]
  people <- gsub("^ ", "", people)
  people <- gsub("^\\(", "", people)

  if (length(people) > 0) {
    people_link <- paste0("https://github.com/", gsub("@", "", people))

    people_out <- data.frame(
      in_text = people,
      replacement = paste0("[", people, "](", people_link, ")"),
      nchar = nchar(people)
    ) |>
      unique()

    people_out <- people_out[order(people_out$nchar, decreasing = TRUE), ]

    for (i in seq_len(nrow(people_out))) {
      new_news <- gsub(
        people_out[i, "in_text"],
        people_out[i, "replacement"],
        new_news
      )
    }
  }

  cat(new_news, file = news_path)
}
