## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

* `devtools::check_rhub()` returns a NOTE for Windows Server 2022 (R-devel, 64 bit):
❯ checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'
    
It turns out that this NOTE is due to a bug in Miktex and can be ignored (https://github.com/r-hub/rhub/issues/503).
