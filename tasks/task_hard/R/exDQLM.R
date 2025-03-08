#' Create an exDQLM Model Object
#'
#' @param y Numeric vector. The observed time series of length T.
#' @param p Integer. Order of the polynomial trend component.
#' @param harmonics Integer vector. Harmonics for the seasonal component.
#' @param period Numeric. Period for the seasonal component.
#' @param X Matrix (T x K). External regressors (if any).
#' @param transfer_function Logical. Whether to use a transfer function.
#' @param lambda Numeric. Transfer function parameter (if applicable).
#' @param delta Numeric vector (optional). Discount factors for evolution variance.
#' @param variational_params List (optional). Initial values for VB inference.
#' @return An `exDQLM` object.
#' @examples
#' y <- rnorm(100)
#' X <- matrix(rnorm(100 * 2), 100, 2)
#' model <- exDQLM(y, p=2, harmonics=c(1,2), period=12, X=X, transfer_function=FALSE)
#' print(model)
exDQLM <- function(y, p, harmonics, period, X = NULL, transfer_function = FALSE, lambda = NULL,
                   delta = NULL, variational_params = NULL) {
  
  T <- length(y)  
  K <- ifelse(is.null(X), 0, ncol(X))  

  if (transfer_function && is.null(lambda)) {
    stop("lambda must be provided if transfer_function is TRUE")
  }
  
  # Assign a default numeric value to lambda if NULL (for non-transfer case)
  if (is.null(lambda)) lambda <- 0.0

  message("Debug: Calling generate_full_evolution_matrices...")
  G_t <- generate_full_evolution_matrices(p, harmonics, period, K, transfer_function, lambda, X)
  message("Debug: G_t dimensions: ", dim(G_t)[1], "x", dim(G_t)[2], "x", dim(G_t)[3])

  message("Debug: Calling generate_full_observation_vectors...")
  F_t <- generate_full_observation_vectors(p, length(harmonics), K, transfer_function, X)
  message("Debug: F_t dimensions: ", dim(F_t)[1], "x", dim(F_t)[2])

  message("Debug: Calling generate_full_m0...")
  m_0 <- generate_full_m0(p, length(harmonics), K, transfer_function)
  message("Debug: m_0 length: ", length(m_0))

  message("Debug: Calling generate_full_C0...")
  C_0 <- generate_full_C0(p, length(harmonics), K, transfer_function)
  message("Debug: C_0 dimensions: ", dim(C_0)[1], "x", dim(C_0)[2])

  structure(
    list(
      y = y,
      F_t = F_t,
      G_t = G_t,
      m_0 = m_0,
      C_0 = C_0,
      delta = delta,
      variational_params = variational_params
    ),
    class = "exDQLM"
  )
}


#' Print Method for exDQLM Objects
#'
#' @param x An `exDQLM` object.
#' @param ... Additional arguments (unused).
print.exDQLM <- function(x, ...) {
  cat("Bayesian Dynamic Quantile Regression Model (exDQLM)\n")
  cat("Number of Observations:", length(x$y), "\n")
  cat("State Dimension:", nrow(x$C_0), "\n")  # Now nrow() should work correctly
  cat("Has Discount Factors:", ifelse(is.null(x$delta), "No", "Yes"), "\n")
  cat("Variational Parameters:", ifelse(is.null(x$variational_params), "Not Initialized", "Initialized"), "\n")
}
