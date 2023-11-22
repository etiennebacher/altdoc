# Import files: README, license, news, CoC ------------------

.import_readme <- function(src_dir, tar_dir, doctype) {
  src_file <- fs::path_join(c(src_dir, "README.md"))
  if (doctype == "quarto_website") {
    tar_file <- fs::path_join(c(tar_dir, "index.md"))
  } else {
    tar_file <- fs::path_join(c(tar_dir, "README.md"))
  }

  # default readme is mandatory for some docs generators
  if (!fs::file_exists(src_file)) {
    writeLines(c("", "Hello world!"), src_file)
  }

  fs::file_copy(src_file, tar_file, overwrite = TRUE)
  .reformat_md(tar_file, first = FALSE)

  # TODO: fix this for Quarto
  if (doctype != "quarto_website") {
    .move_img_readme(path = src_dir)
    .replace_img_paths_readme(path = src_dir)
  }

  cli::cli_alert_success("{.file README} imported.")
}


.import_coc <- function(src_dir, tar_dir, doctype) {
  src_file <- fs::path_join(c(src_dir, "CODE_OF_CONDUCT.md"))
  tar_file <- fs::path_join(c(tar_dir, "CODE_OF_CONDUCT.md"))
  if (fs::file_exists(src_file)) {
    if (!fs::file_exists(tar_file)) {
      cli::cli_alert_success("{.file CODE_OF_CONDUCT} imported for the first time.")
    }
    fs::file_copy(src_file, tar_file, overwrite = TRUE)
    cli::cli_alert_success("{.file CODE_OF_CONDUCT} imported.")
  } else {
    cli::cli_alert_info("No {.file CODE_OF_CONDUCT} to import.")
  }
}


.import_license <- function(src_dir, tar_dir, doctype) {
  src_file <- .which_license(src_dir)
  if (is.null(src_file) || !fs::file_exists(src_file)) {
    cli::cli_alert_info("No {.file LICENSE} to import.")
    return(invisible())
  } else {
    tar1 <- fs::path_join(c(tar_dir, "LICENSE.md"))
    tar2 <- fs::path_join(c(tar_dir, "LICENCE.md"))
    if (!fs::file_exists(tar1) && !fs::file_exists(tar2)) {
      cli::cli_alert_success("{.file LICENSE} imported for the first time.")
    }
    fs::file_copy(src_file, tar_dir, overwrite = TRUE)
    cli::cli_alert_success("{.file LICENSE} imported.")
  }
}


.import_news <- function(src_dir, tar_dir, doctype) {
  src <- .which_news(src_dir)
  if (is.null(src) || !fs::file_exists(src)) {
    cli::cli_alert_info("No {.file NEWS} to import.")
    return(invisible())
  } else {
    tar <- fs::path_join(c(tar_dir, "NEWS.md"))
    if (!fs::file_exists(tar)) {
      cli::cli_alert_success("{.file NEWS} imported for the first time.")
    }
    fs::file_copy(src, tar_dir, overwrite = TRUE)
  }
  .parse_news(path = src_dir, news_path = tar)
  cli::cli_alert_success("{.file NEWS} imported.")
}


# Detect how news files is called: "NEWS" or "CHANGELOG"
.which_news <- function(path = ".") {
  x <- list.files(path = path, pattern = "\\.md$")
  news <- grep("news.md", x, ignore.case = TRUE, value = TRUE)
  changelog <- grep("changelog", x, ignore.case = TRUE, value = TRUE)
  if (length(news) == 1) {
    return(news)
  } else if (length(changelog) == 1) {
    return(changelog)
  } else {
    return(NULL)
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
