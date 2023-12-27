#' Create a "conductor" tour
#'
#' blah blah blah
#' @importFrom R6 R6Class
#' @export
hello_r6 <- R6::R6Class(
  "Conductor",
  private = list(x = 1),

  public = list(

    #' @details
    #' Initialise `Conductor`.
    initialize = function() {},

    #' @param session A valid Shiny session. If `NULL` (default), the function
    #' attempts to get the session with `shiny::getDefaultReactiveDomain()`.
    #'
    #' @details
    #' Initialise `Conductor`.
    init = function(session = NULL) {},

    #' @param title Title of the popover.
    #'
    #' @details
    #' Add a step in a `Conductor` tour.

    step = function(title = NULL) {}
  )
)
