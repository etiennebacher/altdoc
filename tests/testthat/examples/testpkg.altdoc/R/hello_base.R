#' Base function
#'
#' @param x A parameter
#'
#' @return Some value
#' @export
#'
#' @seealso \code{\link[base]{print}}, \code{\link{hello_r6}}
#'
#' @references Ihaka R, Gentleman R (1996).
#'   R: A Language for Data Analysis and Graphics.
#'   \emph{Journal of Computational and Graphical Statistics}. \bold{5}(3), 299--314.
#'   \doi{10.2307/139080}
#'
#' @examples
#' hello_base()
hello_base <- function(x = 2) {
  print("Hello, world!")
}
