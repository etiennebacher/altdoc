
# render_docs

Update documentation

# Description

Render and update the man pages, vignettes, README, Changelog, License,
Code of Conduct, and Reference sections (if ’ they exist). This section
modifies and overwrites the files in the ‘docs/’ folder.

# Usage

<pre><code class='language-R'>render_docs(path = ".", verbose = FALSE, parallel = FALSE, freeze = FALSE)
</code></pre>

# Arguments

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

# Value

No value returned. Updates and overwrites the files in folder ‘docs’.

# Examples

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
