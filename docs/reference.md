# Reference 

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

  preview()

}
```


---
## Update docs

### Description

Render and update the man pages, vignettes, README, Changelog, License,
Code of Conduct, and Reference sections (if ' they exist). This section
modifies and overwrites the files in the 'docs/' folder.

### Usage

    update_docs(path = ".", verbose = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd">
<td><code id="update_docs_:_path">path</code></td>
<td><p>Path to the package root directory.</p></td>
</tr>
<tr class="even">
<td><code id="update_docs_:_verbose">verbose</code></td>
<td><p>TRUE/FALSE. Print the verbose output from Rmarkdown and Quarto
rendering calls.</p></td>
</tr>
</tbody>
</table>

### Value

No value returned. Updates and overwrites the files in folder 'docs'.

### Examples

```r
if (interactive()) {

  update_docs()

}
```


---
## Use

### Description

Initialize documentation website settings

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
<td><p>Path to the package root directory.</p></td>
</tr>
<tr class="even">
<td><code id="use_docute_:_overwrite">overwrite</code></td>
<td><p>TRUE/FALSE. Overwrite the settings files stored in <code
style="white-space: pre;">⁠altdoc/⁠</code>. This is dangerous!</p></td>
</tr>
<tr class="odd">
<td><code id="use_docute_:_verbose">verbose</code></td>
<td><p>TRUE/FALSE. Print the verbose output from Rmarkdown and Quarto
rendering calls.</p></td>
</tr>
<tr class="even">
<td><code id="use_docute_:_update">update</code></td>
<td><p>TRUE/FALSE. Run the <code>update_docs()</code> function
automatically after <code
style="white-space: pre;">⁠use_*()⁠</code>.</p></td>
</tr>
<tr class="odd">
<td><code id="use_docute_:_preview">preview</code></td>
<td><p>TRUE/FALSE. Run the <code>preview()</code> function automatically
after <code style="white-space: pre;">⁠use_*()⁠</code>.</p></td>
</tr>
<tr class="even">
<td><code id="use_docute_:_theme">theme</code></td>
<td><p>Name of the theme to use. Default is basic theme. This is only
available in <code>mkdocs</code>. See Details section.</p></td>
</tr>
</tbody>
</table>

### Details

If you are new to Mkdocs, the themes "readthedocs" and "material" are
among the most popular and developed. You can also see a list of themes
here: <https://github.com/mkdocs/mkdocs/wiki/MkDocs-Themes>.

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
  use_docute()

  # Create docsify documentation
  use_docsify()

  # Create mkdocs documentation
  use_mkdocs()

}
```


---
