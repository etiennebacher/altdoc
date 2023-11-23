.read_freeze <- function(input, output, path, freeze) {
    freeze_file <- fs::path_join(c(path, "altdoc/freeze.rds"))

    if (!isTRUE(freeze) ||
        !fs::file_exists(freeze_file) ||
        !fs::file_exists(input) ||
        !fs::file_exists(output)
        ) {
        return(FALSE)
    }

    .assert_dependency("digest", install = TRUE)

    hashes <- readRDS(freeze_file)

    out <- FALSE

    if (input %in% names(hashes)) {
        old <- hashes[[input]]
        new <- digest::digest(.readlines(input))
        out <- identical(old, new)
    }

    return(out)
}

.write_freeze <- function(input, path, freeze) {
    freeze_file <- fs::path_join(c(path, "altdoc/freeze.rds"))

    if (!fs::file_exists(freeze_file)) {
        hashes <- vector("character")
    } else {
        hashes <- readRDS(freeze_file)
    }

    hashes[[input]] <- digest::digest(.readlines(input))

    saveRDS(hashes, freeze_file)
}