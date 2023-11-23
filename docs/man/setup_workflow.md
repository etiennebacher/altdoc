
# setup_workflow

Create a Github Actions workflow

## Description

This function creates a Github Actions workflow in
".github/workflows/altdoc.yaml". This workflow will automatically render
the website using the setup specified in the folder "altdoc" and will
push the output to the branch "gh-pages".

## Usage

<pre><code class='language-R'>setup_workflow(path = ".")
</code></pre>

## Arguments

<table>
<tr style="vertical-align: top;">
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code>path</code>
</td>
<td>
Path to the package root directory.
</td>
</tr>
</table>

## Value

No value returned. Creates the file ".github/workflows/altdoc.yaml"

## Examples

``` r
library(altdoc)

if (interactive()) {
  setup_workflow()
}
```
