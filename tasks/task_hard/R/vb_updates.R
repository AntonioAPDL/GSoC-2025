#' Update S_t for Variational Bayes
#' @param y Observed data
#' @param exps Expectation of states
#' @return Updated S_t variational parameters
update_sts <- function(y, exps, inv_uts, c2_invb, c_invb, c_a_invb, T) {
  # TODO: Move to C++ for efficiency later
  # Some R implementation here
  return(list(E_sts = updated_sts, E_sts2 = updated_sts2))
}

#' Update U_t for Variational Bayes
update_uts <- function(...) {
  # TODO: Move to C++ for efficiency later
}

#' Update Gamma and Sigma using Laplace Approximation
update_gamma_sigma <- function(...) {
  # TODO: Move to C++ for efficiency later
}
