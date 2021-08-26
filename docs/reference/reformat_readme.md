# `reformat_readme`

Reformat the README


## Description

Reformat the README


## Usage

```r
reformat_readme()
```


## Details

To use Docute, the format of Markdown files has to follow a precise
 structure. There must be at most one main section (starting with '#')
 but there can be as many subsections and subsubsections as you want.
 
 If you saw a message saying that `README.md` was slightly modified, it
 is because the README didn't follow these rules. There probably was several
 main sections, which messed up with Docute organization. Therefore,
 `altdoc` automatically added a '#' to all sections and subsections,
 except the first one, which is usually the title of the package.
 
 For example, if your README looked like this:
 
 list("\n", "# Package\n", "\n", "# Installation\n", "\n", "## Stable version\n", "\n", "## Dev version\n", "\n", "Hello\n", "\n", "# Demo\n", "\n", "Hello again\n") 
 
 It will now look like that:
 
 list("\n", "# Package\n", "\n", "## Installation\n", "\n", "### Stable version\n", "\n", "### Dev version\n", "\n", "Hello\n", "\n", "## Demo\n", "\n", "Hello again\n") 
 
 Note that the main structure is preserved: "Stable version" and "Dev
 version" are still subsections of "Installation".
 
 Also, if your README includes R comments in code chunks, these will not
 be modified.


