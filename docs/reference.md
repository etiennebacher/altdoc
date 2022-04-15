# Reference 

## Init

### Description

Init Docute, Docsify, or Mkdocs

### Usage

    use_docute(convert_vignettes = FALSE, overwrite = FALSE)

    use_docsify(convert_vignettes = FALSE, overwrite = FALSE)

    use_mkdocs(theme = NULL, convert_vignettes = FALSE, overwrite = FALSE)

### Arguments

<table data-summary="R argblock">
<tbody>
<tr class="odd" data-valign="top">
<td><code>convert_vignettes</code></td>
<td><p>Do you want to convert and import vignettes if you have some? This will not modify files in the folder 'vignettes'. This feature is experimental.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>overwrite</code></td>
<td><p>Overwrite the folder 'docs' if it already exists. If <code>FALSE</code> (default), there will be an interactive choice to make in the console to overwrite. If <code>TRUE</code>, the folder 'docs' is automatically overwritten.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>theme</code></td>
<td><p>Name of the theme to use. Default is basic theme. See Details section.</p></td>
</tr>
</tbody>
</table>

### Details

If you are new to Mkdocs, the themes "readthedocs" and "material" are
among the most popular and developed. You can also see a list of themes
here: https://github.com/mkdocs/mkdocs/wiki/MkDocs-Themes.

### Value

No value returned. Creates files in folder 'docs'. Other files and
folders are not modified.

### Examples

```r
## Not run: 
# Create docute documentation
use_docute()

## End(Not run)
## Not run: 
# Create docsify documentation
use_docsify()

## End(Not run)
## Not run: 
# Create mkdocs documentation
use_mkdocs()

## End(Not run)
```


---
## Preview

### Description

Preview the documentation in a webpage or in viewer

### Usage

    preview()

### Value

No value returned. If RStudio is used, it shows a site preview in
Viewer.

### Examples


```r
## Not run: 
# Preview documentation
preview()

## End(Not run)
```


---
## Reformat md

### Description

Reformat Markdown files

### Usage

    reformat_md(file, first = FALSE)

### Arguments

<table data-summary="R argblock">
<tbody>
<tr class="odd" data-valign="top">
<td><code>file</code></td>
<td><p>Markdown file to reformat</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>first</code></td>
<td><p>Should the first title also be reformatted? Default is <code>FALSE</code>.</p></td>
</tr>
</tbody>
</table>

### Details

To use Docute or Docsify, the format of Markdown files has to follow a
precise structure. There must be at most one main section (starting with
'\#') but there can be as many subsections and subsubsections as you
want.

If you saw a message saying that `README.md` was slightly modified, it
is because the README didn't follow these rules. There were probably
several main sections, which messed up Docute/Docsify documentation.
Therefore, `altdoc` automatically added a '\#' to all sections and
subsections, except the first one, which is usually the title of the
package.

For example, if your README looked like this:

    # Package

    # Installation

    ## Stable version

    ## Dev version

    Hello

    # Demo

    Hello again

It will now look like that:

    # Package

    ## Installation

    ### Stable version

    ### Dev version

    Hello

    ## Demo

    Hello again

Note that the main structure is preserved: "Stable version" and "Dev
version" are still subsections of "Installation".

Also, if your README includes R comments in code chunks, these will not
be modified.


---
## Update docs

### Description

Update README, Changelog, License, Code of Conduct, and Reference
sections (if they exist). Convert and add new of modified vignettes to
the documentation. This will leave every other files unmodified.

### Usage

    update_docs(convert_vignettes = FALSE)

### Arguments

<table data-summary="R argblock">
<tbody>
<tr class="odd" data-valign="top">
<td><code>convert_vignettes</code></td>
<td><p>Automatically convert and import vignettes if you have some. This will not modify files in the folder 'vignettes'.</p></td>
</tr>
</tbody>
</table>

### Value

No value returned. Updates files in folder 'docs'.

### Examples

```r
## Not run: 
# Update documentation
update_docs()

## End(Not run)
```


---
