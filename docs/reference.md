# Reference 

## Init

### Description

Init Docute, Docsify, or Mkdocs

### Usage

    use_docute(
      path = ".",
      overwrite = FALSE,
      verbose = FALSE,
      update = getOption("altdoc_update", default = FALSE),
      preview = getOption("altdoc_preview", default = FALSE)
    )

    use_docsify(
      path = ".",
      overwrite = FALSE,
      verbose = FALSE,
      update = getOption("altdoc_update", default = FALSE),
      preview = getOption("altdoc_preview", default = FALSE)
    )

    use_mkdocs(
      path = ".",
      overwrite = FALSE,
      verbose = FALSE,
      update = getOption("altdoc_update", default = FALSE),
      preview = getOption("altdoc_preview", default = FALSE),
      theme = NULL
    )

### Arguments

<table>
<tbody>
<tr class="odd">
<td><code id="use_docute_:_path">path</code></td>
<td><p>Path. Default is the package root (detected with
<code>here::here()</code>).</p></td>
</tr>
<tr class="even">
<td><code id="use_docute_:_overwrite">overwrite</code></td>
<td><p>Overwrite the folder 'docs' if it already exists. If
<code>FALSE</code> (default), there will be an interactive choice to
make in the console to overwrite. If <code>TRUE</code>, the folder
'docs' is automatically overwritten.</p></td>
</tr>
<tr class="odd">
<td><code id="use_docute_:_verbose">verbose</code></td>
<td><p>Logical. If true, the function will print the verbose output from
Rmarkdown and Quarto rendering. (Reference).</p></td>
</tr>
<tr class="even">
<td><code id="use_docute_:_preview">preview</code></td>
<td><p>Logical. Whether a preview of the documentation should be
displayed in a browser window.</p></td>
</tr>
<tr class="odd">
<td><code id="use_docute_:_theme">theme</code></td>
<td><p>Name of the theme to use. Default is basic theme. See Details
section.</p></td>
</tr>
</tbody>
</table>

### Details

If you are new to Mkdocs, the themes "readthedocs" and "material" are
among the most popular and developed. You can also see a list of themes
here: <https://github.com/mkdocs/mkdocs/wiki/MkDocs-Themes>.

### Value

No value returned. Creates files in folder 'docs'. Other files and
folders are not modified.

### Vignettes

Note that although vignettes are automatically moved to the `⁠/docs⁠`
folder, they are no longer automatically specified in the website
structure-defining file. Developers must now manually update this file
and the desired order of their articles. This file lives at the root of
`⁠/docs⁠` and its name differs based on the selected site builder
(`use_docsify()` = `⁠_sidebar.md⁠`; `use_docute()` = `index.html`;
`use_mkdocs()` = `mkdocs.yml`).

### Examples

```r
if (interactive()) {
  # Create docute documentation
  use_docute()

  # Create docsify documentation
  use_docsify()

  # Create mkdocs documentation
  use_mkdocs()
}
```


---
## Preview

### Description

Preview the documentation in a webpage or in viewer

### Usage

    preview(path = ".")

### Arguments

<table>
<tbody>
<tr class="odd">
<td><code id="preview_:_path">path</code></td>
<td><p>Path. Default is the package root (detected with
<code>here::here()</code>).</p></td>
</tr>
</tbody>
</table>

### Value

No value returned. If RStudio is used, it shows a site preview in
Viewer.

### Examples

```r
if (interactive()) {
  # Preview documentation
  preview()
}
```


---
## Update docs

### Description

Update README, Changelog, License, Code of Conduct, and Reference
sections (if they exist). Convert and add new of modified vignettes to
the documentation. This will leave every other files unmodified.

### Usage

    update_docs(path = ".", verbose = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd">
<td><code id="update_docs_:_path">path</code></td>
<td><p>Path. Default is the package root (detected with
<code>here::here()</code>).</p></td>
</tr>
<tr class="even">
<td><code id="update_docs_:_verbose">verbose</code></td>
<td><p>Logical. If true, the function will print the verbose output from
Rmarkdown and Quarto rendering. (Reference).</p></td>
</tr>
</tbody>
</table>

### Value

No value returned. Updates files in folder 'docs'.

### Examples

```r
if (interactive()) {
  # Update documentation
  update_docs()
}
```


---
