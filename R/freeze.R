# input = original man page or vignette
# output = rendered man page or vignette (md file)
# hashes = content of altdoc/freeze.rds
.is_frozen <- function(input, output, hashes) {
    if (!fs::file_exists(input) || !fs::file_exists(output) || is.null(hashes)) {
        return(FALSE)
    }
    if (grepl("/vignettes/", input)) {
      input <- paste0("vignettes/", basename(input))
    }
    out <- FALSE
    if (input %in% names(hashes)) {
        old <- hashes[[input]]
        new <- digest::digest(.readlines(input))
        out <- identical(old, new)
    }
    out
}

# src_dir = path to package root
# src_files = either all vignettes or all man pages
# successes = indices of src_files whose conversion succeeded
# fails = indices of src_files whose conversion failed
# type = "man" or "vignettes"
.update_freeze <- function(src_dir, src_files, successes, fails, type) {
    freeze_file <- fs::path_join(c(src_dir, "altdoc/freeze.rds"))

    if (type == "man") {
        src_files <- paste0("man/", src_files, ".Rd")
    } else if (type == "vignettes") {
        src_files <- paste0("vignettes/", src_files)
    }

    files_success <- src_files[successes]
    files_fail <- src_files[fails]

    if (!fs::file_exists(freeze_file)) {
        hashes <- vector("character")
    } else {
        hashes <- readRDS(freeze_file)
    }

    for (i in src_files) {
        if (i %in% files_success) {
            hashes[[i]] <- digest::digest(.readlines(i))
        } else if (i %in% files_fail) {
            hashes <- hashes[names(hashes) != i]
        }
    }
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
