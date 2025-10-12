# .add_pkgdown() works

    Code
      cat(.readlines("altdoc/pkgdown.yml"), sep = "\n")
    Output
      altdoc: 0.0.0
      pandoc: 0.0.0
      pkgdown: 0.0.0
      last_built: 2020-01-01T00:00:00+0000
      urls:
        reference: https://mywebsite.com/man
        article: https://mywebsite.com/vignettes

---

    Code
      cat(.readlines("altdoc/pkgdown.yml"), sep = "\n")
    Output
      altdoc: 0.0.0
      pandoc: 0.0.0
      pkgdown: 0.0.0
      last_built: 2020-01-01T00:00:00+0000
      articles:
        polars: polars.html
        install: install.html
      urls:
        reference: https://anotherwebsite.com/man
        article: https://anotherwebsite.com/vignettes

