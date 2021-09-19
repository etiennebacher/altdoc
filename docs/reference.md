# Reference 

## Preview

### Description

Preview the documentation in a webpage or in viewer

### Usage

    preview()


---
## Reformat md

### Description

Reformat Markdown files

### Usage

    reformat_md(file)

### Arguments

<table data-summary="R argblock">
<tbody>
<tr class="odd" data-valign="top">
<td><code>file</code></td>
<td><p>Markdown file to reformat</p></td>
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

Update README, Changelog and Reference sections. This will leave every
other files unmodified.

### Usage

    update_docs()


---
## Use docsify

### Description

Init docsify

### Usage

    use_docsify()


---
## Use docute

### Description

Init docute

### Usage

    use_docute()


---
