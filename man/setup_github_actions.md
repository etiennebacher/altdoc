

# Create a Github Actions workflow

[**Source code**](https://github.com/etiennebacher/altdoc/tree/main/R/setup_github_actions.R#L17)

## Description

This function creates a Github Actions workflow in
".github/workflows/altdoc.yaml". This workflow will automatically render
the website using the setup specified in the folder "altdoc" and will
push the output to the branch "gh-pages".

## Usage

<pre><code class='language-R'>setup_github_actions(path = ".")
</code></pre>

## Arguments

<table role="presentation">
<tr>
<td style="white-space: collapse; font-family: monospace; vertical-align: top">
<code id="path">path</code>
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
library("altdoc")

if (interactive()) {
  setup_github_actions()
}
```
