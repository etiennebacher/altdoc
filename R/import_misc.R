
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


.import_basic <- function(src_dir, tar_dir, name = "NEWS") {
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
  if (name == "NEWS") {
    .parse_news(path = src_dir, news_path = tar)
  }

  cli::cli_alert_success("{.file {name}} imported.")
}


# Autolink news, PR, and people in NEWS
.parse_news <- function(path, news_path) {
  if (!fs::file_exists(news_path)) {
    return(invisible())
  }

  orig_news <- .readlines(news_path)

  ### Issues

  issues_pr <- unlist(
    regmatches(
      orig_news,
      gregexpr("\\[[^\\[]*#\\d+(*SKIP)(*FAIL)|#\\d+", orig_news, perl = TRUE)
    )
  )
  new_news <- paste(orig_news, collapse = "\n")
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

  people <- unlist(
    regmatches(orig_news, gregexpr("(^|[^@\\w])@(\\w{1,50})\\b", orig_news))
  )
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