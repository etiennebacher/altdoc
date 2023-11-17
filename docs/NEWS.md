# News

## altdoc (development version)

Breaking changes:

* Functions renamed:
  - `use_docute()`, `use_docsify()` and `use_mkdocs()` are combined into `setup_docs()` 
  - `update_docs()` -> `render_docs()`
  - `preview()` -> `preview_docs()`
* `setup_docs()` functions no longer update and preview the website by default.
* `custom_reference` argument is removed. See the `Post-processing` vignette for a description of the new proposed workflow.
* `theme` argument is removed. Users can change themes by editing settings files in `altdoc/`
* `mkdocs` documentation is no longer stored in `docs/docs/`

New:

* Support for Quarto vignettes (.qmd) stored in the `vignettes/` folder.
* Settings files are now permanently stored in the `altdoc/` directory. These files can be edited manually to customize the website.
* `update` argument in `use_*()` allows users to create a documentation structure without rendering the vignettes and documentation.
* `preview` argument in `use_*()` allows users to suppress the web preview by supplying an explicit argument or a global option.
* Major internal changes to the .Rd -> .md conversion system. We now use Quarto to convert man pages and execute examples, and the man pages are stored in separate markdown files instead of combined in a single large file.
* `mkdocs` now behaves like the other documentation generators and stores its files in `docs/`. This means that `mkdocs` websites can be deployed to Github Pages.
* Improved vignettes

## altdoc 0.2.2

* If necessary, two spaces are automatically added in nested lists in the `NEWS` 
  (or `Changelog`) file. 
  
* This is the last release before a large rework of this package.

## altdoc 0.2.1

* Fix test failures on CRAN due to the new version of `usethis` 
  (see https://github.com/cynkra/fledge/issues/683).

## altdoc 0.2.0 

#### Breaking changes

* Vignettes are no longer automatically added to the file that defines the structure
  of the website. Developers must now manually update this structure and the order
  of their articles. Note that the name of the file defining the structure of the 
  website differs based on the selected site builder. This file lives at the root
  of `/docs` (`use_docsify()` = `_sidebar.md`; `use_docute()` = `index.html`; 
  `use_mkdocs()` = `mkdocs.yml`).
  

#### Major changes
  
* `update_docs()` now updates the package version as well as altdoc version in 
  the footer.
  
* The NEWS or Changelog file included in the docs now automatically links issues,
  pull requests and users (only works for projects on Github).
  
* Vignettes are now always rendered by `use_*()` or `update_docs()`. Therefore,
  the argument `convert_vignettes` is removed. Previously, they were only rendered 
  if their content changed. This was problematic because the code in a vignette 
  can have different output while the vignette in itself doesn't change ([#37](https://github.com/etiennebacher/altdoc/issues/37), [#38](https://github.com/etiennebacher/altdoc/issues/38)).
  
* New argument `custom_reference` in `use_*()` and `update_docs()`. If it is a
  path to a custom R file then it uses this file to build the "Reference" section
  in the docs ([#35](https://github.com/etiennebacher/altdoc/issues/35)).
  
#### Minor changes

* Fix some CRAN failures.


## altdoc 0.1.0

* First version.