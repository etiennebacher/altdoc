altdoc was removed from CRAN due to a `NOTE` happening only on Fedora about
"non-standard things in the check directory". This release disables some tests
on CRAN to reduce the risk of removal.

Timeline:

- 15 Feb. 2026: I receive the email to fix errors (due to changes in R-devel)
  before 1 March.
- 17 Feb. 2026: altdoc 0.7.1 is submitted and published on CRAN, without any
  notice that there is something left to be fixed.
- 1 March 2026: altdoc is removed from CRAN.
