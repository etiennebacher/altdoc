
# render_docs

[**Source code**](https://github.com/etiennebacher/altdoc/tree/main/R/#L)

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

## Altdoc variables

The settings files in the `altdoc/` directory can include `$ALTDOC`
variables which are replaced automatically by <code>altdoc</code> when
calling <code>render_docs()</code>:

<ul>
<li>

`$ALTDOC_PACKAGE_NAME`: Name of the package from
<code>DESCRIPTION</code>.

</li>
<li>

`$ALTDOC_PACKAGE_VERSION`: Version number of the package from
<code>DESCRIPTION</code>

</li>
<li>

`$ALTDOC_PACKAGE_URL`: First URL listed in the DESCRIPTION file of the
package.

</li>
<li>

`$ALTDOC_PACKAGE_URL_GITHUB`: First URL that contains "github.com" from
the URLs listed in the DESCRIPTION file of the package. If no such URL
is found, lines containing this variable are removed from the settings
file.

</li>
<li>

`$ALTDOC_MAN_BLOCK`: Nested list of links to the individual help pages
for each exported function of the package. The format of this block
depends on the documentation generator.

</li>
<li>

`$ALTDOC_VIGNETTE_BLOCK`: Nested list of links to the vignettes. The
format of this block depends on the documentation generator.

</li>
<li>

`$ALTDOC_VERSION`: Version number of the altdoc package.

</li>
</ul>

Also note that you can store images and static files in the `altdoc/`
directory. All the files in this folder are copied to `docs/` and made
available in the root of the website, so you can link to them easily.

## Altdoc preambles

When you call <code>render_docs()</code>, <code>altdoc</code> will
automatically paste the content of one of these three files to the top
of a document:

<ul>
<li>

<code>altdoc/preamble_vignettes_qmd.yml</code>

</li>
<li>

<code>altdoc/preamble_vignettes_rmd.yml</code>

</li>
<li>

<code>altdoc/preamble_man_qmd.yml</code>

</li>
</ul>

The README file uses the vignette preamble.

To preempt this behavior, add your own preamble to the README file or to
a vignette.

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
