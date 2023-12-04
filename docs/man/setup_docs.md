
# setup_docs

Initialize documentation website settings

## Description

Creates a subdirectory called `altdoc/` in the package root directory to
store the settings files used to by one of the documentation generator
utilities (<code>docsify</code>, <code>docute</code>,
<code>mkdocs</code>, or <code>quarto_website</code>). The files in this
folder are never altered automatically by <code>altdoc</code> unless the
user explicitly calls <code>overwrite=TRUE</code>. They can thus be
edited manually to customize the sidebar and website.

## Usage

<pre><code class='language-R'>setup_docs(tool, path = ".", overwrite = FALSE)
</code></pre>

## Arguments

<table>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="setup_docs_:_tool">tool</code>
</td>
<td>
String. "docsify", "docute", "mkdocs", or "quarto_website".
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="setup_docs_:_path">path</code>
</td>
<td>
Path to the package root directory.
</td>
</tr>
<tr>
<td style="white-space: nowrap; font-family: monospace; vertical-align: top">
<code id="setup_docs_:_overwrite">overwrite</code>
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

`vignettes/` stores the vignettes in <code>.md</code>, <code>.Rmd</code>
or <code>.qmd</code> format.

</li>
<li>

`docs/` stores the rendered website. This folder is overwritten every
time a user calls <code>render_docs()</code>, so you should not edit it
manually.

</li>
<li>

`altdoc/` stores the settings files created by
<code>setup_docs()</code>. These files are never modified automatically
after initialization, so you can edit them manually to customize the
settings of your documentation and website. All the files stored in
`altdoc/` are copied to `docs/` and made available as static files in
the root of the website.

</li>
<li>

These files are imported automatically: <code>NEWS.md</code>,
<code>CHANGELOG.md</code>, <code>CODE_OF_CONDUCT.md</code>,
<code>LICENSE.md</code>, <code>LICENCE.md</code>.

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
