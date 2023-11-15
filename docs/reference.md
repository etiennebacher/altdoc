# Reference 

## Preview docs
---------------------------------------------------

### Description

Preview the documentation in a webpage or in viewer

### Usage

    preview_docs(path = ".")

### Arguments

<table>
<tbody>
<tr class="odd">
<td><code id="preview_docs_:_path">path</code></td>
<td><p>Path to the package root directory.</p></td>
</tr>
</tbody>
</table>

### Value

No value returned. If RStudio is used, it shows a site preview in
Viewer. To preview the site in a browser or in another text editor (ex:
VS Code), see the vignette on the `altdoc` website. '

### Examples

```r
if (interactive()) {

  preview_docs()

}
```


---
## Render docs
--------------------

### Description

Render and update the man pages, vignettes, README, Changelog, License,
Code of Conduct, and Reference sections (if ' they exist). This section
modifies and overwrites the files in the 'docs/' folder.

### Usage

    render_docs(
      path = ".",
      verbose = FALSE,
      preview = getOption("altdoc_preview", default = FALSE)
    )

### Arguments

<table>
<tbody>
<tr class="odd">
<td><code id="render_docs_:_path">path</code></td>
<td><p>Path to the package root directory.</p></td>
</tr>
</tbody>
</table>

### Value

No value returned. Updates and overwrites the files in folder 'docs'.

### Examples

```r
if (interactive()) {

  render_docs()

}
```


---
## Setup docs
-----------------------------------------

### Description

Initialize documentation website settings

### Usage

    setup_docs(tool, path = ".", overwrite = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd">
<td><code id="setup_docs_:_tool">tool</code></td>
<td><p>String. "docsify", "docute", or "mkdocs".</p></td>
</tr>
<tr class="even">
<td><code id="setup_docs_:_path">path</code></td>
<td><p>Path to the package root directory.</p></td>
</tr>
<tr class="odd">
<td><code id="setup_docs_:_overwrite">overwrite</code></td>
<td><p>Logical. If TRUE, overwrite existing files.</p></td>
</tr>
</tbody>
</table>

### Value

No value returned.

This function creates a subdirectory called `⁠altdoc/⁠` in the package
root directory. `⁠altdoc/⁠` stores the settings files used to by each of
the documentation generator utilities (docsify, docute, or mkdocs). The
files in this folder are never altered automatically by `altdoc` unless
the user explicitly calls `overwrite=TRUE`. They can thus be edited
manually to customize the sidebar and website.

### Examples

```r
if (interactive()) {

  # Create docute documentation
  setup_docs(tool = "docute")

  # Create docsify documentation
  setup_docs(tool = "docsify")

  # Create mkdocs documentation
  setup_docs(tool = "mkdocs")

}
```


---
