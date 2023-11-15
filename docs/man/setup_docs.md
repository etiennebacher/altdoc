
# setup_docs

Initialize documentation website settings

## Description

Initialize documentation website settings

## Usage

<pre><code class='language-R'>setup_docs(tool, path = ".", overwrite = FALSE)
</code></pre>

## Arguments

<table>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="setup_docs_:_tool">tool</code>
</td>
<td>
String. "docsify", "docute", or "mkdocs".
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="setup_docs_:_path">path</code>
</td>
<td>
Path to the package root directory.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="setup_docs_:_overwrite">overwrite</code>
</td>
<td>
Logical. If TRUE, overwrite existing files.
</td>
</tr>
</table>

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
