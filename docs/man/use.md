
# use

Initialize documentation website settings

## Description

Initialize documentation website settings

## Usage

<pre><code class='language-R'>use_docute(
  path = ".",
  overwrite = FALSE,
  verbose = FALSE,
  update_docs = getOption("altdoc_update_docs", default = FALSE),
  preview = getOption("altdoc_preview", default = FALSE)
)

use_docsify(
  path = ".",
  overwrite = FALSE,
  verbose = FALSE,
  update_docs = getOption("altdoc_update_docs", default = FALSE),
  preview = getOption("altdoc_preview", default = FALSE)
)

use_mkdocs(
  path = ".",
  overwrite = FALSE,
  verbose = FALSE,
  update_docs = getOption("altdoc_update_docs", default = FALSE),
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
Path to the package root directory.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="use_docute_:_overwrite">overwrite</code>
</td>
<td>
TRUE/FALSE. Overwrite the settings files stored in
<code style="white-space: pre;">⁠altdoc/⁠</code>. This is dangerous!
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="use_docute_:_verbose">verbose</code>
</td>
<td>
TRUE/FALSE. Print the verbose output from Rmarkdown and Quarto rendering
calls.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="use_docute_:_update_docs">update_docs</code>
</td>
<td>
TRUE/FALSE. Run the <code>update_docs()</code> function automatically
after <code style="white-space: pre;">⁠use\_\*()⁠</code>.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="use_docute_:_preview">preview</code>
</td>
<td>
TRUE/FALSE. Run the <code>preview_docs()</code> function automatically after
<code style="white-space: pre;">⁠use\_\*()⁠</code>.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="use_docute_:_theme">theme</code>
</td>
<td>
Name of the theme to use. Default is basic theme. This is only available
in <code>mkdocs</code>. See Details section.
</td>
</tr>
</table>

## Details

If you are new to Mkdocs, the themes "readthedocs" and "material" are
among the most popular and developed. You can also see a list of themes
here:
<a href="https://github.com/mkdocs/mkdocs/wiki/MkDocs-Themes">https://github.com/mkdocs/mkdocs/wiki/MkDocs-Themes</a>.

## Value

No value returned.

This function creates a subdirectory called
<code style="white-space: pre;">⁠altdoc/⁠</code> in the package root
directory. <code style="white-space: pre;">⁠altdoc/⁠</code> stores the
settings files used to by each of the documentation generator utilities
(docsify, docute, or mkdocs). The files in this folder are never altered
automatically by <code>altdoc</code> unless the user explicitly calls
<code>overwrite=TRUE</code>. They can thus be edited manually to
customize the sidebar and website.

## Examples

``` r
library(altdoc)

if (interactive()) {

  # Create docute documentation
  setup_docs(tool = "docute")

  # Create docsify documentation
  setup_docs(tool = "docsify")

  # Create mkdocs documentation
  setup_docs(tool = "mkdocs")

}
```
