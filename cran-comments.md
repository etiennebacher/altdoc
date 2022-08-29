## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

* `devtools::check_rhub()` returns a NOTE for Windows Server 2022 (R-devel, 64 bit):
❯ checking for detritus in the temp directory ... NOTE
  Found the following files/directories:
    'lastMiKTeXException'
    
It turns out that this NOTE is due to a bug in Miktex and can be ignored (https://github.com/r-hub/rhub/issues/503).

Answers to comments following the second submission:

> \dontrun{} should only be used if the example really cannot be executed
(e.g. because of missing additional software, missing API keys, ...) by
the user. That's why wrapping examples in \dontrun{} adds the comment
("# Not run:") as a warning for the user.
>Does not seem necessary.
>Please unwrap the examples if they are executable in < 5 sec, or replace
\dontrun{} with \donttest{} or explain why \dontrun{} is really
necassary in these cases.

I removed \dontrun{} calls.
