
# preview

Preview the documentation in a webpage or in viewer

## Description

Preview the documentation in a webpage or in viewer

## Usage

<pre><code class='language-R'>preview(path = ".")
</code></pre>

## Arguments

<table>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="preview_:_path">path</code>
</td>
<td>
Path to the package root directory.
</td>
</tr>
</table>

## Value

No value returned. If RStudio is used, it shows a site preview in
Viewer. To preview the site in a browser or in another text editor (ex:
VS Code), see the vignette on the <code>altdoc</code> website. ’

## Examples

``` r
library(altdoc)

if (interactive()) {

  preview()

}
```
