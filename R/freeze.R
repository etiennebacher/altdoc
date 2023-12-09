.read_freeze <- function(input, output, hashes) {

    if (!fs::file_exists(input) || !fs::file_exists(output) ||is.null(hashes)) {
        return(FALSE)
    }

    out <- FALSE
    if (input %in% names(hashes)) {
        old <- hashes[[input]]
        new <- digest::digest(.readlines(input))
        out <- identical(old, new)
    }
    return(out)
}

.write_freeze <- function(input, path, freeze, worked = TRUE) {
    freeze_file <- fs::path_join(c(path, "altdoc/freeze.rds"))

    if (!fs::file_exists(freeze_file)) {
        hashes <- vector("character")
    } else {
        hashes <- readRDS(freeze_file)
    }

    if (isTRUE(worked)) {
        hashes[[input]] <- digest::digest(.readlines(input))
    } else {
        hashes <- hashes[names(hashes) != input]
    }

    saveRDS(hashes, freeze_file)
}

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
