
# setup_docs

Initialize documentation website settings

## Description

Creates a subdirectory called
<code style="white-space: pre;">⁠altdoc/⁠</code> in the package root
directory to store the settings files used to by one of the
documentation generator utilities (<code>docsify</code>,
<code>docute</code>, <code>mkdocs</code>, or
<code>quarto_website</code>). The files in this folder are never altered
automatically by <code>altdoc</code> unless the user explicitly calls
<code>overwrite=TRUE</code>. They can thus be edited manually to
customize the sidebar and website.

## Usage

<pre><code class='language-R'>setup_docs(tool, path = ".", overwrite = FALSE)
</code></pre>

## Arguments

<table>
<tr style="vertical-align: top;">
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code>tool</code>
</td>
<td>
String. "docsify", "docute", "mkdocs", or "quarto_website".
</td>
</tr>
<tr style="vertical-align: top;">
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code>path</code>
</td>
<td>
Path to the package root directory.
</td>
</tr>
<tr style="vertical-align: top;">
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code>overwrite</code>
</td>
<td>
Logical. If TRUE, overwrite existing files. Warning: This will
completely delete the settings files in the <code>altdoc</code>
directory, including any customizations you may have made.
</td>
</tr>
</table>

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

  # Create quarto website documentation
  setup_docs(tool = "quarto_website")
}
```
