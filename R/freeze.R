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
.write_freeze <- function(input, src_dir, freeze) {
    freeze_file <- fs::path_join(c(src_dir, "altdoc/freeze.rds"))

    if (!fs::file_exists(freeze_file)) {
        hashes <- vector("character")
    } else {
        hashes <- readRDS(freeze_file)
    }

    hashes[[input]] <- digest::digest(.readlines(input))
    saveRDS(hashes, freeze_file)
}

# src_dir = path to package root
# freeze = TRUE/FALSE
.get_hashes <- function(src_dir, freeze) {
    hashes <- NULL
    if (isTRUE(freeze)) {
        freeze_file <- fs::path_join(c(src_dir, "altdoc/freeze.rds"))
        if (fs::file_exists(freeze_file)) {
            .assert_dependency("digest", install = TRUE)
            hashes <- readRDS(freeze_file)
        }
    }
}
