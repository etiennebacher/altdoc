
# render_docs

[**Source code**](https://github.com/etiennebacher/altdoc/tree/readme_fig_path/R/#L)

Update documentation

## Description

Render and update the function reference manual, vignettes, README,
NEWS, CHANGELOG, LICENSE, and CODE_OF_CONDUCT sections, if they exist.
This function overwrites the content of the ‘docs/’ folder. See details
below.

## Usage

<pre><code class='language-R'>render_docs(path = ".", verbose = FALSE, parallel = FALSE, freeze = FALSE)
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
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="render_docs_:_parallel">parallel</code>
</td>
<td>
Logical. Render man pages and vignettes in parallel using the
<code>future</code> framework. In addition to setting this argument to
TRUE, users must define the parallelism plan in <code>future</code>. See
the examples section below.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="render_docs_:_freeze">freeze</code>
</td>
<td>
Logical. If TRUE and a man page or vignette has not changed since the
last call to <code>render_docs()</code>, that file is skipped. File
hashes are stored in <code>altdoc/freeze.rds</code>. If that file is
deleted, all man pages and vignettes will be rendered anew.
</td>
</tr>
</table>

## Details

This function searches the root directory and the `inst/` directory for
specific filenames, renders/converts/copies them to the `docs/`
directory. The order of priority for each file is established as
follows:

<ul>
<li>

<code>docs/README.md</code>

<ul>
<li>

README.md, README.qmd, README.Rmd

</li>
</ul>
</li>
<li>

<code>docs/NEWS.md</code>

<ul>
<li>

NEWS.md, NEWS.txt, NEWS, NEWS.Rd

</li>
<li>

Note: Where possible, Github contributors and issues are linked
automatically.

</li>
</ul>
</li>
<li>

<code>docs/CHANGELOG.md</code>

<ul>
<li>

CHANGELOG.md, CHANGELOG.txt, CHANGELOG

</li>
</ul>
</li>
<li>

<code>docs/CODE_OF_CONDUCT.md</code>

<ul>
<li>

CODE_OF_CONDUCT.md, CODE_OF_CONDUCT.txt, CODE_OF_CONDUCT

</li>
</ul>
</li>
<li>

<code>docs/LICENSE.md</code>

<ul>
<li>

LICENSE.md, LICENSE.txt, LICENSE

</li>
</ul>
</li>
<li>

<code>docs/LICENCE.md</code>

<ul>
<li>

LICENCE.md, LICENCE.txt, LICENCE

</li>
</ul>
</li>
</ul>

## Examples

``` r
library(altdoc)

if (interactive()) {

  render_docs()

  # parallel rendering
  library(future)
  plan(multicore)
  render_docs(parallel = TRUE)

}
```
