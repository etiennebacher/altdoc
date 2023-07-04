# Reference 

## Custom-doc-name

### Description

Function description

### Usage

    foo()

### My Section

    x <- data.frame(PRODUCT = c("A", "B", "C"), PCT_OF_SALE = c("20%", "50%", "30%"))
    knitr::kable(x)

<table>
<tbody>
<tr class="odd">
<td style="text-align: left;">PRODUCT</td>
<td style="text-align: left;">PCT_OF_SALE</td>
</tr>
<tr class="even">
<td style="text-align: left;">A</td>
<td style="text-align: left;">20%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">B</td>
<td style="text-align: left;">50%</td>
</tr>
<tr class="even">
<td style="text-align: left;">C</td>
<td style="text-align: left;">30%</td>
</tr>
<tr class="odd">
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
</tr>
</tbody>
</table>


---
## Init

### Description

Init Docute, Docsify, or Mkdocs

### Usage

    use_docute(path = ".", overwrite = FALSE, custom_reference = NULL)

    use_docsify(path = ".", overwrite = FALSE, custom_reference = NULL)

    use_mkdocs(
      theme = NULL,
      path = ".",
      overwrite = FALSE,
      custom_reference = NULL
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
<td><code
id="use_docute_:_custom_reference">custom_reference</code></td>
<td><p>Path to the file that will be sourced to generate the "Reference"
section.</p></td>
</tr>
<tr class="even">
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

    update_docs(path = ".", custom_reference = NULL)

### Arguments

<table>
<tbody>
<tr class="odd">
<td><code id="update_docs_:_path">path</code></td>
<td><p>Path. Default is the package root (detected with
<code>here::here()</code>).</p></td>
</tr>
<tr class="even">
<td><code
id="update_docs_:_custom_reference">custom_reference</code></td>
<td><p>Path to the file that will be sourced to generate the "Reference"
section.</p></td>
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
