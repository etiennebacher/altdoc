
# init

Init Docute, Docsify, or Mkdocs

## Description

Init Docute, Docsify, or Mkdocs

## Usage

<pre><code class='language-R'>use_docute(
  path = ".",
  overwrite = FALSE,
  update = getOption("altdoc_update", default = FALSE),
  preview = getOption("altdoc_preview", default = FALSE)
)

use_docsify(
  path = ".",
  overwrite = FALSE,
  update = getOption("altdoc_update", default = FALSE),
  preview = getOption("altdoc_preview", default = FALSE)
)

use_mkdocs(
  path = ".",
  overwrite = FALSE,
  update = getOption("altdoc_update", default = FALSE),
  preview = getOption("altdoc_preview", default = FALSE),
  theme = NULL
)
</code></pre>

## Arguments

<table>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="use_docute_:_path">path</code>
</td>
<td>
Path. Default is the package root (detected with
<code>here::here()</code>).
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="use_docute_:_overwrite">overwrite</code>
</td>
<td>
Overwrite the folder ‘docs’ if it already exists. If <code>FALSE</code>
(default), there will be an interactive choice to make in the console to
overwrite. If <code>TRUE</code>, the folder ‘docs’ is automatically
overwritten.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="use_docute_:_preview">preview</code>
</td>
<td>
Logical. Whether a preview of the documentation should be displayed in a
browser window. (Reference).
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="use_docute_:_theme">theme</code>
</td>
<td>
Name of the theme to use. Default is basic theme. See Details section.
</td>
</tr>
</table>

## Details

If you are new to Mkdocs, the themes "readthedocs" and "material" are
among the most popular and developed. You can also see a list of themes
here:
<a href="https://github.com/mkdocs/mkdocs/wiki/MkDocs-Themes">https://github.com/mkdocs/mkdocs/wiki/MkDocs-Themes</a>.

## Value

No value returned. Creates files in folder ‘docs’. Other files and
folders are not modified.

## Vignettes

Note that although vignettes are automatically moved to the
<code style="white-space: pre;">⁠/docs⁠</code> folder, they are no longer
automatically specified in the website structure-defining file.
Developers must now manually update this file and the desired order of
their articles. This file lives at the root of
<code style="white-space: pre;">⁠/docs⁠</code> and its name differs based
on the selected site builder (<code>use_docsify()</code> =
<code style="white-space: pre;">⁠\_sidebar.md⁠</code>;
<code>use_docute()</code> = <code>index.html</code>;
<code>use_mkdocs()</code> = <code>mkdocs.yml</code>).

## Examples

``` r
library(altdoc)

if (interactive()) {
  # Create docute documentation
  use_docute()

  # Create docsify documentation
  use_docsify()

  # Create mkdocs documentation
  use_mkdocs()
}
```
