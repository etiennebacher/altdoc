
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
Path. Default is the package root (detected with
<code>here::here()</code>).
</td>
</tr>
</table>

## Value

No value returned. If RStudio is used, it shows a site preview in
Viewer.

## Examples

``` r
library(altdoc)

if (interactive()) {
  # Preview documentation
  preview()
}
```
