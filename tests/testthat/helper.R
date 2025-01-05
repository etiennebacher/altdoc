library(fs)
library(usethis)
library(withr)

### Don't run mkdocs in other places than my laptop
### It requires installing pip3 and mkdocs, which is not possible on CRAN
### (to my knowledge)
skip_mkdocs <- function() {
  skip_on_cran()
  skip_if_not(.venv_exists())
}


### Taken from {usethis} (file "R/project.R")

proj <- new.env(parent = emptyenv())

proj_get_ <- function() proj$cur

proj_set_ <- function(path) {
  old <- proj$cur
  proj$cur <- path
  invisible(old)
}



### Taken from {usethis} (file "tests/testthat/helper.R")

create_local_package <- function(
    dir = fs::file_temp(pattern = "testpkg"),
    env = parent.frame(),
    rstudio = TRUE) {
  create_local_thing(dir, env, rstudio, "package")
}


create_local_project <- function(
    dir = fs::file_temp(pattern = "testproj"),
    env = parent.frame(),
    rstudio = FALSE) {
  create_local_thing(dir, env, rstudio, "project")
}


create_local_thing <- function(
    dir = fs::file_temp(pattern = pattern),
    env = parent.frame(),
    rstudio = FALSE,
    thing = c("package", "project")) {
  thing <- match.arg(thing)
  if (fs::dir_exists(dir)) {
    ui_stop("Target {ui_code('dir')} {.file {dir}} already exists.")
  }

  old_project <- proj_get_() # this could be `NULL`, i.e. no active project
  old_wd <- getwd() # not necessarily same as `old_project`

  withr::defer(
    {
      try(fs::dir_delete(dir))
    },
    envir = env
  )
  usethis::ui_silence(
    switch(thing,
      package = create_package(dir, rstudio = rstudio, open = FALSE, check_name = FALSE),
      project = create_project(dir, rstudio = rstudio, open = FALSE)
    )
  )

  defer(proj_set(old_project, force = TRUE), envir = env)
  proj_set(dir)

  defer(
    {
      setwd(old_wd)
    },
    envir = env
  )
  setwd(proj_get())

  invisible(proj_get())
}


expect_proj_file <- function(...) expect_true(fs::file_exists(proj_path(...)))
