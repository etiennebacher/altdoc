## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

* `devtools::check_rhub()` returns a NOTE for Windows Server 2022 (R-devel, 64 bit):
❯ checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'
    
It turns out that this NOTE is due to a bug in Miktex and can be ignored (https://github.com/r-hub/rhub/issues/503).

Answers to comments following the first submission:

> If there are references describing the methods in your package, please add these in the description field of your DESCRIPTION file in the form
authors (year) <doi:...>
authors (year) <arXiv:...>
authors (year, ISBN:...)
or if those are not available: <https:...>
with no space after 'doi:', 'arXiv:', 'https:' and angle brackets for auto-linking.
(If you want to add a title as well please put it in quotes: "Title")

I have put https links into angle brackets.

> You have examples for unexported functions. Please either omit these examples or export these functions. e.g. between.Rd

Done.

> Please ensure that your functions do not write by default or in your examples/vignettes/tests in the user's home filespace (including the package directory and getwd()). This is not allowed by CRAN policies.
Please omit any default path in writing functions. In your examples/vignettes/tests you can write to tempdir(). 

> Please always make sure to reset to user's options(), working directory or par() after you changed it in examples and vignettes and demos.
e.g.:
oldwd <- getwd()
...
setwd(...)
...
setwd(oldwd)

Examples are wrapped into `\dontrun{}`, there are no vignettes, and almost all
tests run in `tempdir`. 

Some functions write files by default in the package directory but this is the 
purpose of these functions and this is clearly documented. I think this behavior
is comparable to other packages such as `usethis` that write files directly in
the package directory.
