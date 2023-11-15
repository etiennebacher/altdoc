
# render_docs

Update documentation

## Description

Render and update the man pages, vignettes, README, Changelog, License,
Code of Conduct, and Reference sections (if ’ they exist). This section
modifies and overwrites the files in the ‘docs/’ folder.

## Usage

<pre><code class='language-R'>render_docs(path = ".", verbose = FALSE)
</code></pre>

## Arguments

<table>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="render_docs_:_path">path</code>
</td>
<td>
Path to the package root directory.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="render_docs_:_verbose">verbose</code>
</td>
<td>
Logical. Print Rmarkdown or Quarto rendering output.
</td>
</tr>
</table>

## Value

No value returned. Updates and overwrites the files in folder ‘docs’.

## Examples

``` r
library(altdoc)

if (interactive()) {

  render_docs()

}
```
