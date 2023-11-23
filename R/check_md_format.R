# check if there is only 1 level-one structure
.check_md_structure <- function(file_path) {
  if (!fs::file_exists(file_path)) {
    return(invisible())
  }

  content <- .readlines(file_path)
  idx <- grep("^```", content)

  # backticks are incorrectly paired. We don't know what to do.
  if (length(idx) %% 2 != 0) {
    return(invisible())
  }

  # drop code blocks
  backtick_pairs <- rev(split(idx, ceiling(seq_along(idx) / 2)))
  for (p in backtick_pairs) {
    content[p[1]:p[2]] <- NA
  }
  content <- stats::na.omit(content)

  # too many level 1 header
  if (isTRUE(sum(grepl("^# ", content)) > 1)) {
    cli::cli_alert_danger("Too many level 1 headings in {.file basename(file_path)}. {.code altdoc} assumes that the only level 1 heading is the title of the document. All other subheadings should be at least level 2, starting with: {.code ##}")
  }
}