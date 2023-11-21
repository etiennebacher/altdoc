# Import files: README, license, news, CoC ------------------

.import_readme <- function(src_dir, tar_dir, doctype) {

  if (fs::file_exists(fs::path_abs("README.md", start = src_dir))) {
    src <- fs::path_join(c(src_dir, "README.md"))
  } else {
    src <- system.file("docsify/README.md", package = "altdoc")
  }

  if (doctype == "quarto_website") {
    tar <- fs::path_join(c(tar_dir, "index.md"))
  } else {
    tar <- fs::path_join(c(tar_dir, "README.md"))
  }

  fs::file_copy(src, tar, overwrite = TRUE)

  .reformat_md(tar, first = FALSE)

  # TODO: fix this for Quarto
  if (doctype != "quarto_website") {
    .move_img_readme(path = src_dir)
    .replace_img_paths_readme(path = src_dir)
  }

}


.import_coc <- function(src_dir, tar_dir, doctype) {
  fn <- fs::path_join(c(src_dir, "CODE_OF_CONDUCT.md"))
  if (fs::file_exists(fn)) {
    .update_file(fn, tar_dir, doctype = doctype)
    cli::cli_alert_success("{.file Code of Conduct} imported.")
  } else {
    cli::cli_alert_info("No {.file Code of Conduct} to include.")
  }
}


.import_license <- function(src_dir, tar_dir, doctype) {
  file <- .which_license(src_dir)
  if (is.null(file)) {
    cli::cli_alert_info("No {.file License / Licence} to include.")
    return(invisible())
  }
  if (fs::file_exists(file)) {
    .update_file(file, tar_dir, doctype = doctype)
  }
}


.import_news <- function(src_dir, tar_dir, doctype) {
  src <- .which_news(src_dir)
  tar <- fs::path_join(c(tar_dir, "NEWS.md"))

  if (is.null(src) || !fs::file_exists(src)) {
    cli::cli_alert_info("No {.file NEWS / Changelog} to include.")
    return(invisible())
  }

  .update_file(src, path = tar_dir, doctype = doctype)
  .parse_news(path = src_dir, news_path = tar)
}


# Detect how news files is called: "NEWS" or "CHANGELOG"
# If no news, return "news" for cli message in .update_file()
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
