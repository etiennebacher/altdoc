# Convert and unite .Rd files to 'docs/reference.md'.
.import_man <- function(path = ".", verbose = FALSE, parallel = FALSE) {
  # source and target file paths
  # using here::here() breaks tests, so we rely on directory check higher up
  man_source <- list.files(path = "man", pattern = "\\.Rd$")
  man_target <- list.files(path = fs::path_join(c(.doc_path("."), "man")), pattern = "\\.md$")
  man_source <- fs::path_ext_remove(man_source)
  man_target <- fs::path_ext_remove(man_target)

  n <- length(man_source)


  cli::cli_alert_info("Found {n} man page{?s} to convert.")

  # process man pages one by one
  render_one_man <- function(fn) {
    # fs::path_ext_set breaks filenames with dots, ex: 'foo.bar.Rd'
    origin_Rd <- fs::path_join(c("man", paste0(fn, ".Rd")))
    destination_dir <- fs::path_join(c(.doc_path(path = "."), "man"))
    destination_qmd <- fs::path_join(c(destination_dir, paste0(fn, ".qmd")))
    destination_md <- fs::path_join(c(destination_dir, paste0(fn, ".md")))
    fs::dir_create(destination_dir)
    .rd2qmd(origin_Rd, destination_dir)
    worked <- .qmd2md(destination_qmd, destination_dir, verbose = verbose)
    fs::file_delete(destination_qmd)
    # section headings are too deeply nested by default
    # this is a hack because it may remove one # from comments. But that's
    # probably not the end of the world, because the line stick stays commented
    # out.
    if (fs::file_exists(destination_md)) {
      tmp <- .readlines(destination_md)
      tmp <- gsub("^##", "#", tmp)
      writeLines(tmp, destination_md)
    }
    return(worked)
  }

  if (isTRUE(parallel)) {
    .assert_dependency("future.apply", install = TRUE)
    conversion_worked <- future.apply::future_sapply(man_source, render_one_man, future.seed = NULL)
  } else {
    # can't use message_info with {}
    i <- 0
    cli::cli_progress_step("Converting {cli::qty(n)}man page{?s}: {i}/{n}", spinner = TRUE)
    conversion_worked <- vector(length = n)
    for (i in seq_along(man_source)) {
      conversion_worked[i] <- render_one_man(man_source[i])
      cli::cli_progress_update(inc = 1)
    }
  }

  successes <- which(conversion_worked == TRUE)
  fails <- which(conversion_worked == FALSE)
  cli::cli_progress_done()

  # indent bullet points
  cli::cli_div(theme = list(ul = list(`margin-left` = 2, before = "")))

  if (length(fails) > 0) {
    cli::cli_par()
    cli::cli_end()
    cli::cli_alert_danger("{cli::qty(length(successes))}The conversion failed for the following man page{?s}:")
    cli::cli_ul(id = "list-fail")
    for (i in seq_along(fails)) {
      cli::cli_li("{.file {man_source[fails[i]]}}")
    }
    cli::cli_par()
    cli::cli_end(id = "list-fail")
  }
}


.rd2qmd <- function(source_file, target_dir) {
  if (missing(source_file) || !file.exists(source_file)) {
    stop("source_file must be a valid file path.", call. = FALSE)
  }
  if (missing(source_file) || !dir.exists(target_dir)) {
    stop("target_dir must be a valid directory.", call. = FALSE)
  }

  # Rd -> html
  rd <- tools::parse_Rd(source_file)
  tmp_html <- paste0(tempfile(), ".html")
  tools::Rd2HTML(rd, out = tmp_html)

  # superfluous header and footer
  tmp <- .readlines(tmp_html)
  tmp <- tmp[(grep("</table>$", tmp)[1] + 1):length(tmp)]
  tmp <- tmp[seq_len(which("</div>" == tmp) - 3)]

  # first column (odd entries) of table in Arguments should not be wrapped
  idx <- grep("<td>", tmp)
  idx <- idx[seq_along(idx) %% 2 == 1]
  tmp[idx] <- sub("<td>", '<td style = "white-space: nowrap; font-family: monospace; vertical-align: top">', tmp[idx])

  # math in Equivalence section
  idx <- grepl("<.code", tmp)

  # examples: evaluate code blocks (assume examples are always last)
  pkg <- basename(getwd())
  pkg_load <- paste0("library(", pkg, ")")
  idx <- which(tmp == "<h3>Examples</h3>")
  if (length(idx) == 1) {
    ex <- tmp[(idx + 1):length(tmp)]
    ex <- gsub("<.*>", "", ex)
    ex <- gsub("&lt;", "<", ex)
    ex <- gsub("&gt;", ">", ex)
    ex <- gsub("&gt;", ">", ex)
    ex <- ex[!grepl("## Not run:", ex)]
    ex <- ex[!grepl("## End", ex)]

    # respect \dontrun{} and \donttest{}. This is too aggressive because it
    # ignores all tests whenever one of the two tags appear anywhere, but it
    # would be very hard to parse different examples wrapped or not wrapped in a
    # \donttest{}.
    block <- !any(grepl("dontrun|donttest|## Not run:", tmp))
    block <- sprintf("```{r, warning=FALSE, message=FALSE, eval=%s}", block)
    tmp <- c(tmp[2:idx], block, pkg_load, ex, "```")
  }

  # cleanup equations
  tmp <- gsub(
    '<code class="reqn">(.*?)&gt;(.*?)</code>',
    '<code class="reqn">\\1>\\2</code>',
    tmp
  )
  tmp <- gsub(
    '<code class="reqn">(.*?)&lt;(.*?)</code>',
    '<code class="reqn">\\1<\\2</code>',
    tmp
  )
  tmp <- gsub('<code class="reqn">(.*?)</code>', "\\$\\1\\$", tmp)

  # title
  # warning: Undefined global functions or variables: title
  title <- "not NULL"
  funname <- tools::file_path_sans_ext(basename(source_file))
  if (!is.null(title)) {
    tmp <- tmp[!grepl("h1", tmp)]
    tmp <- c(paste("##", funname, "{.unnumbered}\n"), tmp)
  }

  # Fix title level (use ## and not <h2> so that the TOC can be generated by
  # mkdocs)
  tmp <- gsub("<h2[^>]*>", "", tmp, perl = TRUE)
  tmp <- gsub("<.h2>", "", tmp)
  tmp <- gsub("<h3>", "### ", tmp)
  tmp <- gsub("</h3>", "", tmp)

  # paragraph tags are unnecessary in markdown
  tmp <- gsub("<p>", "", tmp, fixed = TRUE)
  tmp <- gsub("</p>", "", tmp, fixed = TRUE)

  # write to file
  fn <- file.path(target_dir, sub("Rd$", "qmd", basename(source_file)))
  writeLines(tmp, con = fn)
}
