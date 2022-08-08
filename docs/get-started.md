# Get started

## Prerequisites

If you want to use `docsify` or `docute`, you can skip this and go directly to the next section.

If you want to use `mkdocs` or its variants (such as `mkdocs-material`), you will first need to install it. To do that, you will need `python` and `pip`. If you have them, you can run: `pip install mkdocs`. Otherwise, a (short) procedure is described [here](https://www.mkdocs.org/user-guide/installation/). Some themes, such as `readthedocs`, are automatically installed with `mkdocs` but most are not. If you want to use `mkdocs-material`, you will also need to run `pip install mkdocs-material`, as described [here](https://squidfunk.github.io/mkdocs-material/getting-started/#with-pip).

## Initialize

You can use `altdoc` at any stage in the development of your package. When you're ready to build a documentation, just call `use_docsify()`, `use_docute()` or `use_mkdocs()`, according to which documentation generator you prefer.

This will create the folder 'docs'. If it already exists, a message will ask whether it should be overwritten. 

The `use_*()` functions will pre-populate your documentation with several files:

* the `README` will be the homepage;
* `NEWS`, `LICENSE` and `CODE_OF_CONDUCT` (if they exist) will be sections;
* all `.Rd` files will be aggregated in a single file, called `reference.md`. If you don't want some functions to be referenced, you should replace `#'` by `#` in the source code and re-run `devtools::document()`.

## About vignettes

When initializing the documentation, `altdoc` can copy your vignettes in the folder `docs/articles`, modify their YAML to produce Markdown files, render them, and include them in the docs structure. This is controlled by the argument `convert_vignettes` in `use_*()` (this argument is `TRUE` by default).

The reason for changing the YAML is that most vignettes are HTML files (even though sometimes they are also available as PDF files). However, a website made with `docsify`, `docute` or `mkdocs` requires Markdown files, and not HTML files. 

<Note type="info">

Using `convert_vignettes = TRUE` will *not* affect files in the folder `vignettes`.

</Note>

<Note type="warning">

There are several reasons why automatically converting and rendering the vignettes might not work. When using `use_*()`, `altdoc` will let you know which vignettes could be converted and which couldn't. 

</Note>


## Extend 

There are two ways to add some documentation.

The first one is to add new vignettes in the 'vignettes' folder. This will require to run `update_docs()` to add them in the website documentation (cf next section). 

The second one is to create (R) Markdown files in the 'docs' folder. One drawback of this approach is that these files will not be accessible on the CRAN page of your package. Also, if you want to switch to another documentation generator later (such as `{pkgdown}`), you will need to convert these files to vignettes.

Finally, if you manually create (R) Markdown files, or if you want to modify the organization of your website, you will need to modify the sidebar. This is done in different files, depending on the documentation generator you use:

* with `docute`, everything is done in `index.html`. This is where you add sections, options, and other extensions documented [here](https://docute.org).

* with `docsify.js`, the organization of the sidebar is made in `_sidebar.md`, and options and extensions are dealt with in `index.html` (and detailed [here](https://docsify.js.org/#/)).

* with `mkdocs`, the structure is slightly different. In the folder `docs`, the file `mkdocs.yml` takes care of all the layout and options of your documentation. The subfolder `docs` contains the `.md` files. The subfolder `site` is created automatically, there is no need to modify it.

## Update 

Once you have initialized and extended your documentation, you can continue developing your package and call `update_docs()` when you need to update the documentation.

More specifically, `update_docs()` will:

* update the README, the NEWS and the "Reference" section if there were some changes;

* import the License and the Code of Conduct if they were created after having initialized the docs;

* convert new vignettes and update the modified ones.



