#' @section Freeze
#' 
#' When working on a package, running `render_docs()` to preview changes can be a time-consuming road block. The argument `freeze = TRUE` tries to improve the experience by preventing rerendering of files that have not changed since the last time `render_docs()` was ran. Note that changes to package internals will not cause a rerender, so rerendering the entire docs can still be necessary. 
#' 
#' For non-Quarto formats, this is done by creating a `freeze.rds` file in `altdoc/` that is able to determine which documentation files have changed. 
#' 
#' For the Quarto format, we rely on the [Quarto freeze](https://quarto.org/docs/projects/code-execution.html#freeze) feature. Freezing a document needs to be set either at a project or per-file level. Freezing a document needs to be set either at a project or per-file level. To do so, add to either `quarto_website.yml` or the frontmatter of a file:
#'  ``` yml
#'  execute:
#'    freeze: auto
#'  ```
#' 
