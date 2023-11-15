
# update_docs

Update documentation

## Description

Render and update the man pages, vignettes, README, Changelog, License,
Code of Conduct, and Reference sections (if ’ they exist). This section
modifies and overwrites the files in the ‘docs/’ folder.

## Usage

<pre><code class='language-R'>update_docs(
  path = ".",
  verbose = FALSE,
  preview = getOption("altdoc_preview", default = FALSE)
)
</code></pre>

## Arguments

<table>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="update_docs_:_path">path</code>
</td>
<td>
Path to the package root directory.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="update_docs_:_verbose">verbose</code>
</td>
<td>
TRUE/FALSE. Print the verbose output from Rmarkdown and Quarto rendering
calls.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="update_docs_:_preview">preview</code>
</td>
<td>
TRUE/FALSE. Run the <code>preview_docs()</code> function automatically after
<code style="white-space: pre;">⁠use\_\*()⁠</code>.
</td>
</tr>
</table>

## Value

No value returned. Updates and overwrites the files in folder ‘docs’.

## Examples

``` r
library(altdoc)

if (interactive()) {

  update_docs()

}
```
