# input = original man page or vignette
# output = rendered man page or vignette (md file)
# hashes = content of altdoc/freeze.rds
.is_frozen <- function(input, output, hashes) {
    if (!fs::file_exists(input) || !fs::file_exists(output) || is.null(hashes)) {
        return(FALSE)
    }
    out <- FALSE
    if (input %in% names(hashes)) {
        old <- hashes[[input]]
        new <- digest::digest(.readlines(input))
        out <- identical(old, new)
    }
    out
}

# input = filename
# src_dir = path to package root
# freeze = TRUE/FALSE
# worked = TRUE/FALSE - did the conversion of the file work?
.write_freeze <- function(input, freeze, worked) {
    fn <- "altdoc/freeze.rds"
    if (!fs::file_exists(fn)) {
        hashes <- vector("character")
    } else {
        hashes <- readRDS(fn)
    }

    # if conversion failed we don't want to store the hash of the input because
    # it contains an error
    if (isTRUE(worked)) {
        hashes[[input]] <- digest::digest(.readlines(input))
    } else {
        hashes <- hashes[names(hashes) != input]
    }

    saveRDS(hashes, fn)
}

# src_dir = path to package root
# freeze = TRUE/FALSE
.get_hashes <- function(freeze) {
    hashes <- NULL
    if (isTRUE(freeze)) {
        if (fs::file_exists("altdoc/freeze.rds")) {
            .assert_dependency("digest", install = TRUE)
            hashes <- readRDS("altdoc/freeze.rds")
        }
    }
}
