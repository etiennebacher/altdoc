Get Started
================

## Quick start

To create, render, and preview a new documentation website, execute
these commands from the root directory of your package:

``` r
library(altdoc)

### Initialize
use_docsify()
## use_docute()
## use_mkdocs()

### Render
update_docs()

### Preview
preview()
```

Below, we explain in more detail what these commands do.

## Installation

``` r
install.packages("altdoc")
```

To create documentation websites with either `docsify` or `docute`, you
only need to install `altdoc` in `R`.

To use `mkdocs` or its variants (such as `mkdocs-material`), you will
first need to install those packages in `Python` using a tool like
`pip`. From the command line:

``` python
pip install mkdocs mkdocs-material
```

See the [`mkdocs`](https://www.mkdocs.org/user-guide/installation/) and
[`mkdocs-material`](https://squidfunk.github.io/mkdocs-material/getting-started/#with-pip)
installation guides for details.

## Package structure

`altdoc` makes assumptions about your package structure:

- `vignettes/` stores the vignettes in `.md`, `.Rmd` or `.qmd` format.
- `docs/` stores the rendered website. This folder is overwritten every
  time a user calls `update_docs()`, so you should not edit it manually.
- `altdoc/` stores the settings files created by `use_*()` functions.
  These files are never modified automatically after initialization, so
  you can edit these files manually to change the settings of your
  documentation and website. All the files stored in `altdoc/` are
  copied to `docs/` and made available as static files in the root of
  the website.
- `README.md` is the homepage of the website.
- The content of the (optional) “news” section is stored in `NEWS.md` or
  `CHANGELOG.md`
- The content of the (optional) “code of conduct” section is stored in
  `CODE_OF_CONDUCT.md`.
- The license is stored in `LICENSE.md` or `LICENSE.md`.

## Initialize

These functions initialize a documentation website structure:
`use_docsify()`, `use_docute()` and `use_mkdocs()`. Calling one of them
will:

1.  Create a `docs/` folder
2.  Create a `altdoc/` folder
3.  Add `altdoc/` to `.Rbuildignore`
4.  Copy default settings files to `altdoc/` for the chosen
    documentation generator

## Customize

To customize the documentation, you can edit the settings files in the
`altdoc/` folder. The settings files differ between the different
documentation generators. For example, this is the default `mkdocs.yml`
settings created when one calls `use_mkdocs()`:

``` yaml
site_name: $ALTDOC_PACKAGE_NAME
repo_url: $ALTDOC_PACKAGE_URL
repo_name: $ALTDOC_PACKAGE_NAME
plugins:
  - search
nav:
  - Home: README.md
$ALTDOC_VIGNETTE_BLOCK
  - Changelog: $ALTDOC_NEWS
  - Code of Conduct: $ALTDOC_CODE_OF_CONDUCT
  - License: $ALTDOC_LICENSE
```

By editing this file, you can change the name of the website, the order
of the sections, add new sections or drop irrelevant ones, etc.

The settings files can include `$ALTDOC` variables which are replaced
automatically by `altdoc` when calling `update_docs()`:

- `$ALTDOC_PACKAGE_NAME`: Name of the package from `DESCRIPTION`.
- `$ALTDOC_PACKAGE_VERSION`: Version number of the package from
  `DESCRIPTION`
- `$ALTDOC_PACKAGE_URL`: First URL listed in the DESCRIPTION file of the
  package.
- `$ALTDOC_PACKAGE_URL_GITHUB`: First URL that contains “github.com”
  from the URLs listed in the DESCRIPTION file of the package. If no
  such URL is found, lines containing this variable are removed from the
  settings file.
- `$ALTDOC_MAN_BLOCK`: Nested list of links to the individual help pages
  for each exported function of the package. The format of this block
  depends on the documentation generator.
- `$ALTDOC_VIGNETTE_BLOCK`: Nested list of links to the vignettes. The
  format of this block depends on the documentation generator.
- `$ALTDOC_VERSION`: Version number of the altdoc package.

Also note that you can store images and static files in the `altdoc/`
directory. All the files in this folder are copied to `docs/` and made
available in the root of the website, so you can link to them easily.

Interested readers should refer to their chosen documentation generator
documentation for more details:

- <https://docsify.js.org/>
- <https://docute.egoist.dev/>
- <https://www.mkdocs.org/>

## Render and update

Once the documentation is initialized, you can render it with:

``` r
update_docs()
```

This function will:

1.  Render and copy standard `R` package files to `docs/`.
    - Ex: `NEWS.md`, `README.md`, `LICENSE.md`, `CODE_OF_CONDUCT.md`,
      etc.
2.  Render Rmarkdown and Quarto files (`.Rmd` and `.qmd` extensions)
    from the `vignettes/` directory and store them in `docs/articles/`.
3.  Copy Markdown files with extension `.md` from `vignettes/` to
    `docs/articles/`.
4.  Convert the manual pages stored `man/` from `.Rd` to `.md` format,
    and copy them to `docs/man/`.
5.  Copy all static files from `altdoc/` to `docs/`.

Whenever you make changes to the man pages or to the vignettes, you can
call `update_docs()` again to render the new files and update the
website.

## Preview

To preview the website, you need to run a local web server.

In RStudio you can launch one automatically in the Preview Pane by
calling:

``` r
preview()
```

In Visual Studio Code, you can use one of the many “live preview” or
“local server” extensions available. For example,

1.  Install the [Live
    Preview](https://marketplace.visualstudio.com/items?itemName=ms-vscode.live-server)
    extension from Microsoft.
2.  From the command palette, select “Live Preview: Start Server”.
3.  When the preview pane opens, navigate to the `docs/` folder.