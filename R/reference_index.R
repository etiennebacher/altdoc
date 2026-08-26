.reference_yaml_path <- function(path) {
    fs::path_join(c(path, "altdoc", "reference.yml"))
}

.read_reference_config <- function(path) {
    fn <- .reference_yaml_path(path)
    if (!fs::file_exists(fn)) {
        return(NULL)
    }
    yaml::yaml.load_file(fn)
}

# Maps every \name{}/\alias{} documented in man/*.Rd to that Rd file's
# basename (the name .render_one_man() uses for the rendered man/<basename>.qmd
# target) and its \title{}, so `reference.yml` entries can refer to a
# function by any of its aliases, not just its Rd filename.
.rd_topic_index <- function(path) {
    rd_files <- fs::dir_ls(fs::path_join(c(path, "man")), regexp = "\\.Rd$")

    index <- list()
    for (rd_file in rd_files) {
        rd <- tools::parse_Rd(rd_file)
        tags <- vapply(rd, function(x) attr(x, "Rd_tag"), character(1))
        aliases <- vapply(
            rd[tags == "\\alias"],
            function(x) as.character(x[[1]]),
            character(1)
        )
        title <- trimws(paste(unlist(rd[tags == "\\title"]), collapse = ""))
        base <- fs::path_ext_remove(basename(rd_file))

        for (alias in aliases) {
            index[[alias]] <- list(basename = base, title = title)
        }
    }
    index
}

# Errors if `reference.yml` lists a name with no matching Rd (typo, most
# likely), and warns if some documented topic isn't listed anywhere in
# `reference.yml` (it just won't appear on the index page).
.validate_reference_config <- function(config, topics) {
    listed <- unlist(lapply(config, function(block) block$contents))

    missing_rd <- setdiff(listed, names(topics))
    if (length(missing_rd) > 0) {
        cli::cli_abort(
            "altdoc/reference.yml lists {.val {missing_rd}}, which {?has/have} no matching \\name{{}}/\\alias{{}} in man/*.Rd."
        )
    }

    unlisted <- setdiff(names(topics), listed)
    if (length(unlisted) > 0) {
        cli::cli_warn(
            "man/*.Rd defines {.val {unlisted}}, which {?is/are} not listed in altdoc/reference.yml and won't appear on the reference index."
        )
    }

    invisible(NULL)
}

.build_reference_index <- function(path, docs_dir) {
    config <- .read_reference_config(path)
    topics <- .rd_topic_index(path)
    .validate_reference_config(config, topics)

    sections <- lapply(config, function(block) {
        entries <- vapply(
            block$contents,
            function(name) {
                topic <- topics[[name]]
                sprintf(
                    '<dt><code><a href="%s.qmd">%s()</a></code></dt>\n<dd>%s</dd>',
                    topic$basename,
                    name,
                    topic$title
                )
            },
            character(1)
        )
        c(
            paste0("## ", block$title),
            "",
            '<dl class="ref-index">',
            paste(entries, collapse = "\n\n"),
            "</dl>",
            ""
        )
    })

    lines <- c(
        '---',
        'title: "Function reference"',
        '---',
        "",
        unlist(sections)
    )
    lines <- lines[-length(lines)] # drop trailing blank line

    out_dir <- fs::path_join(c(docs_dir, "man"))
    fs::dir_create(out_dir)
    writeLines(lines, fs::path_join(c(out_dir, "index.qmd")))
}
