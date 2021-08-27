## `check_docs_exists`

Check that folder 'docs' does not already exist, or is empty.


### Description

Check that folder 'docs' does not already exist, or is empty.


### Usage

```r
check_docs_exists()
```


## `img_paths_readme`

Get the paths of images/GIF in README


### Description

Get the paths of images/GIF in README


### Usage

```r
img_paths_readme()
```


## `make_reference`

Create 'Reference' tab


### Description

Function adapted from [John Coene's code](https://github.com/devOpifex/leprechaun/blob/master/docs/docify.R) 
 
 Convert .Rd to .md files, move them in 'docs/reference', and generate
 the JSON to put in 'docs/index.html'


### Usage

```r
make_reference()
```


## `move_img_readme`

Copy images/GIF that are in README in 'docs/'


### Description

Copy images/GIF that are in README in 'docs/'


### Usage

```r
move_img_readme()
```


## `preview`

Preview the documentation in a webpage or in viewer


### Description

Preview the documentation in a webpage or in viewer


### Usage

```r
preview()
```


## `reformat_readme`

Reformat the README


### Description

Reformat the README


### Usage

```r
reformat_readme()
```


### Details

To use Docute, the format of Markdown files has to follow a precise
 structure. There must be at most one main section (starting with '#')
 but there can be as many subsections and subsubsections as you want.
 
 If you saw a message saying that `README.md` was slightly modified, it
 is because the README didn't follow these rules. There probably was several
 main sections, which messed up with Docute organization. Therefore,
 `altdoc` automatically added a '#' to all sections and subsections,
 except the first one, which is usually the title of the package.
 
 For example, if your README looked like this: list("# Package\n", "\n", "# Installation\n", "\n", "## Stable version\n", "\n", "## Dev version\n", "\n", "Hello\n", "\n", "# Demo\n", "\n", "Hello again\n") 
 
 It will now look like that: list("# Package\n", "\n", "## Installation\n", "\n", "### Stable version\n", "\n", "### Dev version\n", "\n", "Hello\n", "\n", "## Demo\n", "\n", "Hello again\n") 
 
 Note that the main structure is preserved: "Stable version" and "Dev
 version" are still subsections of "Installation".
 
 Also, if your README includes R comments in code chunks, these will not
 be modified.


## `use_docsify`

Init docsify


### Description

Init docsify


### Usage

```r
use_docsify()
```


## `use_docute`

Init docute


### Description

Init docute


### Usage

```r
use_docute()
```


