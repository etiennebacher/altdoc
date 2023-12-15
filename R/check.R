# Check that project is a package -------------------------

.check_is_package <- function(path) {
  if (!.dir_is_package(path)) {
    cli::cli_abort("{.code altdoc} only works in packages.")
  }
}

.check_dependency <- function(library_name) {
  requireNamespace(library_name, quietly = TRUE)
}

.assert_dependency <- function(library_name, install = FALSE) {
  flag <- .check_dependency(library_name)
  msg <- sprintf("This functionality requires the `%s` package.", library_name)
  if (!isTRUE(flag)) {
    if (isTRUE(install)) {
      msg <- sprintf("This functionality requires the `%s` package. Do you want to install it?", library_name)
      if (isTRUE(utils::askYesNo(msg, default = TRUE))) {
        utils::install.packages(library_name)
        return(invisible())
      }
    }
    stop(msg, call. = FALSE)
  }
}


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
    bn <- basename(file_path)
    cli::cli_alert_danger("Too many level 1 headings in `{bn}`. {.code altdoc} assumes that the only level 1 heading is the title of the document. All other subheadings should be at least level 2, starting with: {.code ##}")
  }
}
