# altdoc 0.1.0.9000 (development)

### Breaking changes

* Vignettes are no longer automatically added to the file that defines the structure
  of the website. Developers must now manually update this structure and the order
  of their articles.
  

### Major changes
  
* `update_docs()` now updates the package version as well as altdoc version in 
  the footer.
  
* The NEWS or Changelog file included in the docs now automatically links issues,
  pull requests and users (only works for projects on Github).
  
* Vignettes are now always rendered by `use_*()` or `update_docs()`. Previously,
  they were only rendered if their content changed. This was problematic because
  the code in a vignette can have different output while the vignette in itself
  doesn't change.



# altdoc 0.1.0

* First version.
