

# Update documentation

[**Source code**](https://github.com/etiennebacher/altdoc/tree/main/R/render_docs.R#L49)

## Description

Render and update the function reference manual, vignettes, README,
NEWS, CHANGELOG, LICENSE, and CODE_OF_CONDUCT sections, if they exist.
This function overwrites the content of the ‘docs/’ folder. See details
below.

## Usage

<pre><code class='language-R'>render_docs(path = ".", verbose = FALSE, parallel = FALSE, freeze = FALSE, ...)
</code></pre>

## Arguments

<table>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="path">path</code>
</td>
<td>
Path to the package root directory.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="verbose">verbose</code>
</td>
<td>
Logical. Print Rmarkdown or Quarto rendering output.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="parallel">parallel</code>
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
<code id="freeze">freeze</code>
</td>
<td>
Logical. If TRUE and a man page or vignette has not changed since the
last call to <code>render_docs()</code>, that file is skipped. File
hashes are stored in <code>altdoc/freeze.rds</code>. If that file is
deleted, all man pages and vignettes will be rendered anew.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="...">…</code>
</td>
<td>
Additional arguments are ignored.
</td>
</tr>
</table>

## Details

This function searches the root directory and the
<code style="white-space: pre;">inst/</code> directory for specific
filenames, renders/converts/copies them to the
<code style="white-space: pre;">docs/</code> directory. The order of
priority for each file is established as follows:

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

The settings files in the <code style="white-space: pre;">altdoc/</code>
directory can include <code style="white-space: pre;">$ALTDOC</code>
variables which are replaced automatically by <code>altdoc</code> when
calling <code>render_docs()</code>:

<ul>
<li>

<code style="white-space: pre;">$ALTDOC_PACKAGE_NAME</code>: Name of the
package from <code>DESCRIPTION</code>.

</li>
<li>

<code style="white-space: pre;">$ALTDOC_PACKAGE_VERSION</code>: Version
number of the package from <code>DESCRIPTION</code>

</li>
<li>

<code style="white-space: pre;">$ALTDOC_PACKAGE_URL</code>: First URL
listed in the DESCRIPTION file of the package.

</li>
<li>

<code style="white-space: pre;">$ALTDOC_PACKAGE_URL_GITHUB</code>: First
URL that contains "github.com" from the URLs listed in the DESCRIPTION
file of the package. If no such URL is found, lines containing this
variable are removed from the settings file.

</li>
<li>

<code style="white-space: pre;">$ALTDOC_MAN_BLOCK</code>: Nested list of
links to the individual help pages for each exported function of the
package. The format of this block depends on the documentation
generator.

</li>
<li>

<code style="white-space: pre;">$ALTDOC_VIGNETTE_BLOCK</code>: Nested
list of links to the vignettes. The format of this block depends on the
documentation generator.

</li>
<li>

<code style="white-space: pre;">$ALTDOC_VERSION</code>: Version number
of the altdoc package.

</li>
</ul>

Also note that you can store images and static files in the
<code style="white-space: pre;">altdoc/</code> directory. All the files
in this folder are copied to
<code style="white-space: pre;">docs/</code> and made available in the
root of the website, so you can link to them easily.

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

## Freeze

When working on a package, running <code>render_docs()</code> to preview
changes can be a time-consuming road block. The argument <code>freeze =
TRUE</code> tries to improve the experience by preventing rerendering of
files that have not changed since the last time
<code>render_docs()</code> was ran. Note that changes to package
internals will not cause a rerender, so rerendering the entire docs can
still be necessary.

For non-Quarto formats, this is done by creating a
<code>freeze.rds</code> file in
<code style="white-space: pre;">altdoc/</code> that is able to determine
which documentation files have changed.

For the Quarto format, we rely on the
<a href="https://quarto.org/docs/projects/code-execution.html#freeze">Quarto
freeze</a> feature. Freezing a document needs to be set either at a
project or per-file level. Freezing a document needs to be set either at
a project or per-file level. To do so, add to either
<code>quarto_website.yml</code> or the frontmatter of a file:

<pre>execute:
  freeze: auto
</pre>

## Auto-link for Quarto websites

When the <code>code-link</code> format setting is <code>true</code> in
<code>altdoc/quarto_website.yml</code> and the <code>downlit</code>
package is installed, <code>altdoc</code> will use the
<code>downlit</code> package to replace the function names on the
package website by links to web-based package documentation. This works
for base R libraries and any package published on CRAN.

To allow internal links to functions documented by <code>altdoc</code>,
we need to include links to correct URLs in the
<code>altdoc/pkgdown.yml</code> file. By default, this file is populated
with links to the first URL in the <code>DESCRIPTION</code>.

Importantly, <code>downlit</code> requires the <code>pkgdown.yml</code>
file to be live on the website to create links. This means that links
will generally not be updated when making purely local changes. Also,
links may not be updated the first time an <code>altdoc</code> website
is published to the web.

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
