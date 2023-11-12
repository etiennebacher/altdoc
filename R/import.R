# Import files: README, license, news, CoC ------------------

.import_readme <- function(path = ".") {
  good_path <- .doc_path(path)

  if (fs::file_exists(fs::path_abs("README.md", start = path))) {
    fs::file_copy(
      fs::path_abs("README.md", start = path),
      paste0(good_path, "/README.md"),
      overwrite = TRUE
    )
    cli::cli_alert_success("{.file README} imported.")
  } else {
    fs::file_copy(
      system.file("docsify/README.md", package = "altdoc"),
      fs::path_join(c(good_path, "/README.md")),
      overwrite = TRUE
    )
    cli::cli_alert_info("No {.file README} found. Created a default {.file docs/README}.")
  }
  .reformat_md(paste0(good_path, "/README.md"), first = FALSE)
  .move_img_readme(path = path)
  .replace_img_paths_readme(path = path)
}


.import_coc <- function(path = ".") {
  good_path <- .doc_path(path)
  if (fs::file_exists(fs::path_join(c(path, "CODE_OF_CONDUCT.md")))) {
    .update_file("CODE_OF_CONDUCT.md", path)
    cli::cli_alert_success("{.file Code of Conduct} imported.")
  } else {
    cli::cli_alert_info("No {.file Code of Conduct} to include.")
  }
}


.import_license <- function(path = ".") {
  good_path <- .doc_path(path)
  file <- .which_license()
  if (is.null(file)) {
    cli::cli_alert_info("No {.file License / Licence} to include.")
    return(invisible())
  }
  if (fs::file_exists(file)) {
    .update_file(file, path)
    fs::file_copy(file, paste0(good_path, "/LICENSE.md"), overwrite = TRUE)
    cli::cli_alert_success("{.file {file}} imported.")
  }
}


.import_news <- function(path = ".") {
  good_path <- .doc_path(path)
  file <- .which_news()
  if (is.null(file)) {
    cli::cli_alert_info("No {.file NEWS / Changelog} to include.")
    return(invisible())
  }
  if (fs::file_exists(file)) {
    .update_file(file, path)
    .reformat_md(paste0(good_path, "/", file), first = TRUE)
    .parse_news(path, paste0(good_path, "/NEWS.md"))
    cli::cli_alert_success("{.file {file}} imported.")
  }
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
