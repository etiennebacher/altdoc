library(testthat)
library(altdoc)

# Taken from testthat:::on_cran()
env <- Sys.getenv("NOT_CRAN")
on_cran <- if (identical(env, "")) {
    !interactive()
} else {
    !isTRUE(as.logical(env))
}

if (!on_cran) {
    test_check("altdoc")
}
