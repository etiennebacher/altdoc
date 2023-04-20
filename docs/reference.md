# Reference 

## Init

### Description

Init Docute, Docsify, or Mkdocs

### Usage

    use_docute(
      convert_vignettes = TRUE,
      overwrite = FALSE,
      path = ".",
      custom_reference = NULL
    )

    use_docsify(
      convert_vignettes = TRUE,
      overwrite = FALSE,
      path = ".",
      custom_reference = NULL
    )

    use_mkdocs(
      theme = NULL,
      convert_vignettes = TRUE,
      overwrite = FALSE,
      path = ".",
      custom_reference = NULL
    )

### Arguments

<table>
<tbody>
<tr class="odd" style="vertical-align: top;">
<td><code>convert_vignettes</code></td>
<td><p>Do you want to convert and import vignettes if you have some?
This will not modify files in the folder 'vignettes'. This feature is
experimental.</p></td>
</tr>
<tr class="even" style="vertical-align: top;">
<td><code>overwrite</code></td>
<td><p>Overwrite the folder 'docs' if it already exists. If
<code>FALSE</code> (default), there will be an interactive choice to
make in the console to overwrite. If <code>TRUE</code>, the folder
'docs' is automatically overwritten.</p></td>
</tr>
<tr class="odd" style="vertical-align: top;">
<td><code>path</code></td>
<td><p>Path. Default is the package root (detected with
<code>here::here()</code>).</p></td>
</tr>
<tr class="even" style="vertical-align: top;">
<td><code>custom_reference</code></td>
<td><p>Path to the file that will be sourced to generate the "Reference"
section.</p></td>
</tr>
<tr class="odd" style="vertical-align: top;">
<td><code>theme</code></td>
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
<tr class="odd" style="vertical-align: top;">
<td><code>path</code></td>
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
# Preview documentation
preview()
```


---
## Update docs

### Description

Update README, Changelog, License, Code of Conduct, and Reference
sections (if they exist). Convert and add new of modified vignettes to
the documentation. This will leave every other files unmodified.

### Usage

    update_docs(convert_vignettes = TRUE, path = ".", custom_reference = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" style="vertical-align: top;">
<td><code>convert_vignettes</code></td>
<td><p>Automatically convert and import vignettes if you have some. This
will not modify files in the folder 'vignettes'.</p></td>
</tr>
<tr class="even" style="vertical-align: top;">
<td><code>path</code></td>
<td><p>Path. Default is the package root (detected with
<code>here::here()</code>).</p></td>
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
