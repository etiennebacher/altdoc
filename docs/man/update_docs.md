
# update_docs

Update documentation

## Description

Update README, Changelog, License, Code of Conduct, and Reference
sections (if they exist). Convert and add new of modified vignettes to
the documentation. This will leave every other files unmodified.

## Usage

<pre><code class='language-R'>update_docs(path = ".", verbose = FALSE)
</code></pre>

## Arguments

<table>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="update_docs_:_path">path</code>
</td>
<td>
Path. Default is the package root (detected with
<code>here::here()</code>).
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="update_docs_:_verbose">verbose</code>
</td>
<td>
Logical. If true, the function will print the verbose output from
Rmarkdown and Quarto rendering. (Reference).
</td>
</tr>
</table>

## Value

No value returned. Updates files in folder ‘docs’.

## Examples

``` r
library(altdoc)

if (interactive()) {
  # Update documentation
  update_docs()
}
```
