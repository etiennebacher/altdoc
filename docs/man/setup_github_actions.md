
# setup_github_actions

[**Source code**](https://github.com/etiennebacher/altdoc/tree/readme_fig_path/R/#L)

Create a Github Actions workflow

## Description

This function creates a Github Actions workflow in
".github/workflows/altdoc.yaml". This workflow will automatically render
the website using the setup specified in the folder "altdoc" and will
push the output to the branch "gh-pages".

## Usage

<pre><code class='language-R'>setup_github_actions(path = ".")
</code></pre>

## Arguments

<table>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="setup_github_actions_:_path">path</code>
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
  setup_github_actions()
}
```
