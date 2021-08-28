
## Check that folder 'docs' does not already exist, or is empty.

### Description

Check that folder 'docs' does not already exist, or is empty.

### Usage

    check_docs_exists()


---

## Get the paths of images/GIF in README

### Description

Get the paths of images/GIF in README

### Usage

    img_paths_readme()


---

## Create 'Reference' tab

### Description

Function adapted from [John Coene's
code](https://github.com/devOpifex/leprechaun/blob/master/docs/docify.R)

Convert .Rd to .md files, move them in 'docs/reference', and generate
the JSON to put in 'docs/index.html'

### Usage

    make_reference()


---

## Copy images/GIF that are in README in 'docs/'

### Description

Copy images/GIF that are in README in 'docs/'

### Usage

    move_img_readme()


---

## Preview the documentation in a webpage or in viewer

### Description

Preview the documentation in a webpage or in viewer

### Usage

    preview()


---

## Reformat the README

### Description

Reformat the README

### Usage

    reformat_readme()

### Details

To use Docute, the format of Markdown files has to follow a precise
structure. There must be at most one main section (starting with '#')
but there can be as many subsections and subsubsections as you want.

If you saw a message saying that `README.md` was slightly modified, it
is because the README didn't follow these rules. There probably was
several main sections, which messed up with Docute organization.
Therefore, `altdoc` automatically added a '#' to all sections and
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

## Init docsify

### Description

Init docsify

### Usage

    use_docsify()


---

## Init docute

### Description

Init docute

### Usage

    use_docute()


---
