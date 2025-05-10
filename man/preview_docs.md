

# Preview the documentation in a webpage or in viewer

[**Source code**](https://github.com/etiennebacher/altdoc/tree/main/R/preview_docs.R#L20)

## Description

Preview the documentation in a webpage or in viewer

## Usage

<pre><code class='language-R'>preview_docs(path = ".")
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

No value returned. If RStudio is used, it shows a site preview in
Viewer. To preview the site in a browser or in another text editor (ex:
VS Code), see the vignette on the <code>altdoc</code> website.

## Examples

``` r
library("altdoc")

if (interactive()) {

  preview_docs()

}

# This is an example to illustrate that code-generated images are properly
# displayed. See the `altdoc` website for a rendered version.
with(mtcars, plot(mpg, wt))
```

![](man/preview_docs.markdown_strict_files/figure-markdown_strict/unnamed-chunk-1-1.png)
