# Transform vignettes to produce Markdown
#
# Transform vignettes to produce Markdown instead of HTML.
#
# Vignettes files (originally placed in the folder "Vignettes") have the output
# "html_vignette", instead of Markdown. This function makes several things:
# * moves the .Rmd files from the "vignettes" folder in "docs/articles"
# * replaces the "output" argument of each .Rmd file (in "docs/articles") so
#  that it is "md_document" instead of "html_vignette"
# * render all of the modified .Rmd files (in "docs/articles"), which produce .md files.

transform_vignettes <- function() {

  if (!file.exists("vignettes") | folder_is_empty("vignettes")) {
    cli::cli_alert_info("No vignettes to convert")
    return(invisible())
  }

  good_path <- doc_path()
  articles_path <- paste0(good_path, "/articles")

  vignettes <- list.files("vignettes", pattern = ".Rmd$")

  if (!file.exists(articles_path)) {
    fs::dir_create(articles_path)
  }

  for (i in seq_along(vignettes)) {
    x <- manage_child_vignettes(paste0("vignettes/", vignettes[i]))
    if (!is.null(x) & x == "stop") return(invisible())
  }

  ### Check which vignette is different
  vignette_is_different <- logical(length(vignettes))
  for (i in seq_along(vignettes)) {
    origin <- paste0("vignettes/", vignettes[i])
    destination <- paste0(articles_path, "/", vignettes[i])
    vignette_is_different[i] <- vignettes_differ(origin, destination)
    if (vignette_is_different[i]) {
      fs::file_copy(origin, destination, overwrite = TRUE)
    }
  }
  if (!any(vignette_is_different)) {
    cli::cli_alert_info("No new vignette to convert.")
    return(invisible())
  }

  to_convert <- which(vignette_is_different)
  n <- length(to_convert)
  # can't use message_info with {}
  cli::cli_alert_info("Found {length(to_convert)} vignette{?s} to convert.")
  i <- 0
  cli::cli_progress_step("Converting {cli::qty(n)}vignette{?s}: {i}/{n}", spinner = TRUE)

  for (i in seq_along(to_convert)) {
    j <- to_convert[i] # do that for cli progress step
    origin <- paste0("vignettes/", vignettes[j])
    destination <- paste0(articles_path, "/", vignettes[j])

    modify_yaml(destination)
    extract_import_bib(destination)
    output_file <- paste0(substr(vignettes[j], 1, nchar(vignettes[j])-4), ".md")

    suppressMessages(
      suppressWarnings(
        rmarkdown::render(
          destination,
          output_dir = articles_path,
          output_file = output_file,

          # https://github.com/rstudio/rmarkdown/issues/2331
          # https://github.com/r-lib/roxygen2/pull/1304
          output_options = list(math_method = NULL),

          quiet = TRUE,
          envir = new.env()
        )
      )
    )

    ### If title too long, it was cut in several lines but only the last
    ### one is read by docute so need to paste the title back together
    new_vignette <- readLines(gsub("\\.Rmd", "\\.md", destination), warn = FALSE)
    title_sep <- grep("=====", new_vignette)
    if (length(title_sep) == 1) {
      title <- new_vignette[1:title_sep-1]
      title <- paste(title, collapse = " ")

      # for some reason, having a colon in the title breaks the title when
      # using mkdocs
      if (doc_type() == "mkdocs") {
        title <- gsub(":", " - ", title)
      }

      new_vignette <- new_vignette[-c(1:title_sep-1)]
      new_vignette <- c(title, new_vignette)
      writeLines(new_vignette, gsub("\\.Rmd", "\\.md", destination))
    }

    reformat_md(gsub("\\.Rmd", "\\.md", destination))

    cli::cli_progress_update()
  }

  cli::cli_progress_done()
  cli::cli_alert_success("{cli::qty(n)}Vignette{?s} ha{?s/ve} been converted and put in {.file {articles_path}}.")
  cli::cli_alert_info("The folder {.file {'vignettes'}} was not modified.")
}


# Check if vignettes in folder "vignettes" and in folder "docs/articles" differ
#
# Since the output of the vignette in the folder "vignette" is "html_vignette"
# and the output of the vignette in the folder "docs/articles" is
# "github_document", there will necessarily be changes. Therefore, the
# comparison is made on the files without the YAML.
#
# @param x,y Names of the two vignettes to compare
#
# @return Boolean
# @keywords internal

vignettes_differ <- function(x, y) {

  if (!file.exists(x) | !file.exists(y)) {
    return(TRUE)
  }

  x_file <- readLines(x, warn = FALSE)
  x_file <- x_file[-which(x_file == "")]
  x_content <- gsub("---(.*?)---", "", paste(x_file, collapse = "\n"))

  y_file <- readLines(y, warn = FALSE)
  y_file <- y_file[-which(y_file == "")]
  y_content <- gsub("---(.*?)---", "", paste(y_file, collapse = "\n"))

  return(!identical(x_content, y_content))
}


# Get titles and filenames of the vignettes and returns them in a dataframe
# with two columns: title and link.
# This is used to update the sidebar/navbar in the docs.

get_vignettes_titles <- function() {

  if (!file.exists("vignettes") | folder_is_empty("vignettes")) {
    return(invisible())
  }

  good_path <- doc_path()
  vignettes <- list.files(paste0(good_path, "/articles"), pattern = ".Rmd")

  vignettes_title <- data.frame(title = NULL, link = NULL)
  for (i in seq_along(vignettes)) {
    x <- readLines(paste0(good_path, "/articles/", vignettes[i]), warn = FALSE)
    title <- x[startsWith(x, "title: ")]
    title <- gsub("title: ", "", title)
    vignettes_title[i, "title"] <- title

    link <- paste0("/articles/", vignettes[i])
    link <- gsub("\\.Rmd", "\\.md", link)
    vignettes_title[i, "link"] <- link
  }

  return(vignettes_title)
}

# Add vignettes in the index/sidebar/yaml depending on the tool used.
# This creates a section "Articles" with every vignettes in docs/articles

add_vignettes <- function() {

  doctype <- doc_type()
  vignettes_titles <- get_vignettes_titles()
  if (is.null(vignettes_titles)) {
    return(invisible())
  }
  if (!nrow(vignettes_titles) >= 1) {
    return(invisible())
  }

  if (doctype == "docute") {

    original_index <- readLines("docs/index.html", warn = FALSE)

    if (any(grepl("title: \"Articles\"", original_index))) {
      cli::cli_alert_info("New vignettes were not added automatically in {.file {'docs/index.html'}}. You need to do it manually.")
      return(invisible())
    }

    home_line <- which(grepl("\\{title: 'Home', link: '/'\\}", original_index))

    original_index[home_line] <- paste0(
      original_index[home_line],
      "\n{
					   title: \"Articles\",
					   children:",
      jsonlite::toJSON(vignettes_titles, pretty = TRUE),
      "},\n"
    )

    writeLines(original_index, "docs/index.html")




  } else if (doctype == "docsify") {

    original_sidebar <- readLines("docs/_sidebar.md", warn = FALSE)

    # Remove the articles / vignettes section to avoid duplicates
    if (any(grepl("^\\* \\[Articles\\]\\(\\)", original_sidebar))) {
      vignette_start <- grep("^\\* \\[Articles\\]\\(\\)", original_sidebar)
      vignette_end <- grep("^\\* \\[", original_sidebar)
      vignette_end <- vignette_end[vignette_end > vignette_start][1]-1
      original_sidebar <- original_sidebar[-c(vignette_start:vignette_end)]
    }

    # Insert articles section just below home
    home_line <- which(grepl("\\[Home\\]", original_sidebar))
    original_sidebar[home_line] <- paste0(
      original_sidebar[home_line],
      "\n* [Articles]()",
      paste("\n  * [", vignettes_titles$title, "](", vignettes_titles$link, ")",
            collapse = "", sep = "")
    )

    writeLines(original_sidebar, "docs/_sidebar.md")




  } else if (doctype == "mkdocs") {

    vignettes_titles$link <- gsub("/articles", "articles", vignettes_titles$link)

    original_yaml <- suppressWarnings(yaml::read_yaml("docs/mkdocs.yml"))

    # If articles are in the navbar, remove them, so that there is no duplicates
    nav_sections <- unlist(lapply(original_yaml$nav, names))
    # I will put reference in a section at the end
    if ("Articles" %in% nav_sections) {
      original_yaml$nav[[which(nav_sections == "Articles")]] <- NULL
    }
    if ("articles" %in% nav_sections) {
      original_yaml$nav[[which(nav_sections == "articles")]] <- NULL
    }

    # yaml::as.yaml doesn't format plugins well when there is only one plugin
    if (length(original_yaml$plugins) == 1) {
      original_yaml$plugins <- list(original_yaml$plugins)
    }

    # Create section "Articles" and add vignettes in it
    list_articles <- list("Articles" = NULL)
    for (i in 1:nrow(vignettes_titles)) {
      x <- list(vignettes_titles[i, 2])
      names(x) <- paste0(vignettes_titles[i, 1])
      list_articles[["Articles"]] <- append(
        list_articles[["Articles"]], x, length(list_articles[["Articles"]])
      )
    }

    new_nav <- append(original_yaml$nav, list(list_articles), 1)
    original_yaml$nav <- new_nav
    new_yaml <- yaml::as.yaml(original_yaml)

    # yaml::as.yaml is quite inconsistent with indents and dash, especially with
    # plugins, so I fix indents and dashes only for things after plugin (i.e
    # plugins and nav)
    # TODO: find a more robust solution
    before_plugin <- gsub("plugins:.*", "", new_yaml)
    after_plugin <- gsub(".*?(plugins:)", "\\1", new_yaml)
    after_plugin <- gsub("- ", "  - ", after_plugin)
    after_plugin <- gsub("    ", "    - ", after_plugin)
    after_plugin <- gsub("- -", "-", after_plugin)

    # Put reference and changelog in a section if it isn't already
    if (length(gregexpr("Reference:", after_plugin)[[1]]) == 1) {
      after_plugin <- gsub("Reference:", "Reference:\n    - Reference:", after_plugin)
    }
    if (length(gregexpr("Changelog:", after_plugin)[[1]]) == 1) {
      after_plugin <- gsub("Changelog:", "Changelog:\n    - Changelog:", after_plugin)
    }
    new_yaml <- paste(before_plugin, after_plugin, sep = "")

    writeLines(new_yaml, "docs/mkdocs.yml")
  }
}



# Check whether vignettes call child documents
manage_child_vignettes <- function(file) {

  x  <- tinkr::yarn$new(file)

  children <- x$body
  children <- xml2::xml_find_all(children, xpath = ".//md:code_block", x$ns)
  children <- xml2::xml_attr(children, attr = "child")

  children <- children[!is.na(children)]
  children <- gsub("\"", "", children)

  if(length(children) == 0) return("continue")

  if (any(grepl("\\.\\.", children))) {
    cli::cli_alert_danger("Some vignettes call child elements in other folders. {.code altdoc} cannot deal with them.")
    return("stop")
  } else {
    for (i in children) {
      fs::file_copy(children, paste0("docs/articles/", children), overwrite = TRUE)
      return("continue")
    }
  }

}
