## Initialize the documentation

You can use `altdoc` at any stage in the development of your package. When you're ready to build a documentation, just call `use_docsify()` or `use_docute()`, according to which documentation generator you prefer.

This will create the folder 'docs'. If it already exists, a message will ask whether it should be overwritten. 

The `use_*()` functions will pre-populate your documentation with several files:

* the `README` will be the homepage;
* `NEWS` and `CODE_OF_CONDUCT` (if they exist) will be sections;
* all `.Rd` files will be aggregated in a single file, called `reference.md`. If you don't want some functions to be referenced, you should replace `#'` by `#` in the source code and re-run `devtools::document()`.

## Extend the documentation

To add some documentation, you can create Markdown files in the 'docs' folder. Adding them to the sidebar will require different actions, according to the documentation generator you use:

* with `docute`, everything is done in `index.html`. This is where you add sections, options, and other extensions documented [here](https://docute.org).

* with `docsify.js`, the organization of the sidebar is made in `_sidebar.md`, and options and extensions are dealt with in `index.html` (and detailed [here](https://docsify.js.org/#/)).

## Update the documentation

Some files are likely to be modified quite frequently: the README, the NEWS and the `.Rd` files. To automatically update these files in 'docs', run `update_docs()`. Only those files will be modified. 
