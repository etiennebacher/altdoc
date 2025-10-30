

# Initialize documentation website settings

[**Source code**](https://github.com/etiennebacher/altdoc/tree/main/R/setup_docs.R#L37)

## Description

Creates a subdirectory called
<code style="white-space: pre;">altdoc/</code> in the package root
directory to store the settings files used to by one of the
documentation generator utilities (<code>docsify</code>,
<code>docute</code>, <code>mkdocs</code>, or
<code>quarto_website</code>). The files in this folder are never altered
automatically by <code>altdoc</code> unless the user explicitly calls
<code>overwrite=TRUE</code>. They can thus be edited manually to
customize the sidebar and website.

## Usage

<pre><code class='language-R'>setup_docs(tool, path = ".", overwrite = FALSE)
</code></pre>

## Arguments

<table role="presentation">
<tr>
<td style="white-space: collapse; font-family: monospace; vertical-align: top">
<code id="tool">tool</code>
</td>
<td>
String. "docsify", "docute", "mkdocs", or "quarto_website".
</td>
</tr>
<tr>
<td style="white-space: collapse; font-family: monospace; vertical-align: top">
<code id="path">path</code>
</td>
<td>
Path to the package root directory.
</td>
</tr>
<tr>
<td style="white-space: collapse; font-family: monospace; vertical-align: top">
<code id="overwrite">overwrite</code>
</td>
<td>
Logical. If TRUE, overwrite existing files. Warning: This will
completely delete the settings files in the <code>altdoc</code>
directory, including any customizations you may have made.
</td>
</tr>
</table>

## Package structure

<code>altdoc</code> makes assumptions about your package structure:

<ul>
<li>

The homepage of the website is stored in <code>README.qmd</code>,
<code>README.Rmd</code>, or <code>README.md</code>.

</li>
<li>

<code style="white-space: pre;">vignettes/</code> stores the vignettes
in <code>.md</code>, <code>.Rmd</code> or <code>.qmd</code> format.

</li>
<li>

<code style="white-space: pre;">docs/</code> stores the rendered
website. This folder is overwritten every time a user calls
<code>render_docs()</code>, so you should not edit it manually.

</li>
<li>

<code style="white-space: pre;">altdoc/</code> stores the settings files
created by <code>setup_docs()</code>. These files are never modified
automatically after initialization, so you can edit them manually to
customize the settings of your documentation and website. All the files
stored in <code style="white-space: pre;">altdoc/</code> are copied to
<code style="white-space: pre;">docs/</code> and made available as
static files in the root of the website.

</li>
<li>

These files are imported automatically: <code>NEWS.md</code>,
<code>CHANGELOG.md</code>, <code>CODE_OF_CONDUCT.md</code>,
<code>LICENSE.md</code>, <code>LICENCE.md</code>.

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

## Examples

``` r
library("altdoc")

if (interactive()) {

  # Create docute documentation
  setup_docs(tool = "docute")

  # Create docsify documentation
  setup_docs(tool = "docsify")

  # Create mkdocs documentation
  setup_docs(tool = "mkdocs")

  # Create quarto website documentation
  setup_docs(tool = "quarto_website")
}
```
