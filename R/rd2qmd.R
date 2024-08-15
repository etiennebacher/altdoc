.rd2qmd <- function(source_file, target_dir, path) {
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
  tmp <- utils::head(tmp, -4)

  # first column (odd entries) of table in Arguments should not be wrapped
  idx <- grep("<td>", tmp)
  idx <- idx[seq_along(idx) %% 2 == 1]
  tmp[idx] <- sub("<td>", '<td style = "white-space: nowrap; font-family: monospace; vertical-align: top">', tmp[idx])

  # escape the $ in man pages otherwise it thinks it is a latex equation and
  # doesn't escape symbols between two $.
  tmp <- gsub("\\$", "\\\\$", tmp)

  # process \doi{...} tags that were expanded to \Sexpr[results=rd]{tools:::Rd_expr_doi("...")}
  tmp <- gsub("(\\\\Sexpr\\[results=rd\\]\\{tools:::Rd_expr_doi\\(\\\")([^\\\"]+)(\\\"\\)\\})", "[doi:\\2](https://doi.org/\\2)", tmp)

  # examples: evaluate code blocks (assume examples are always last)
  pkg <- .pkg_name(path)
  pkg_load <- paste0("library(\"", pkg, "\")")
  idx <- which(tmp == "<h3>Examples</h3>")


  # No examples -> early return since we can just wrap everyting in `{=html}`
  if (length(idx) == 0) {
    tmp <- c("```{=html}\n", tmp, "```")
    fn <- file.path(target_dir, sub("Rd$", "qmd", basename(source_file)))
    writeLines(tmp, con = fn)
    return(invisible())
  }

  # until next section or the end
  idx_post_examples <- grep("<h3>", tmp)
  idx_post_examples <- idx_post_examples[idx_post_examples > idx]
  if (length(idx_post_examples) > 0) {
    ex <- tmp[(idx + 1):(idx_post_examples[1] - 1)]
  } else {
    ex <- tmp[(idx + 1):length(tmp)]
  }
  ex <- gsub("<.*>", "", ex)
  ex <- gsub("&lt;", "<", ex)
  ex <- gsub("&gt;", ">", ex)
  ex <- gsub("&amp;", "&", ex)
  ex <- gsub("\\$", "$", ex, fixed = TRUE)
  ex <- ex[!grepl("## Not run:", ex)]
  ex <- ex[!grepl("## End", ex)]

  # respect \dontrun{} and \donttest{}. This is too aggressive because it
  # ignores all tests whenever one of the two tags appear anywhere, but it
  # would be very hard to parse different examples wrapped or not wrapped in a
  # \donttest{}.
  block_eval <- !any(grepl("dontrun|donttest|## Not run:", tmp))

  # hack to support `examplesIf`. This is very ugly and probably fragile
  # added in roxygen2::rd-examples.R
  # https://github.com/r-lib/roxygen2/blob/db4dd9a4de2ce6817c17441d481cf5d03ef220e2/R/rd-examples.R#L17
  regex <- ') (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf'
  exampleIf <- grep(regex, rd, fixed = TRUE)[1]
  if (!is.na(exampleIf[1])) {
    exampleIf <- sub(regex, "", as.character(rd)[exampleIf], fixed = TRUE)
    exampleIf <- sub("^if \\(", "", exampleIf)
    if (!isTRUE(try(eval(parse(text=exampleIf)), silent = TRUE))) {
      block_eval <- FALSE
    }
  }

  block <- sprintf("```{r, warning=FALSE, message=FALSE, eval=%s}", block_eval)

  tmp <- c(
    # Before examples
    "```{=html}\n", tmp[2:idx], "```",
    # Examples
    block, pkg_load, ex, "```"
  )

  # write to file
  fn <- file.path(target_dir, sub("Rd$", "qmd", basename(source_file)))
  writeLines(tmp, con = fn)
}
