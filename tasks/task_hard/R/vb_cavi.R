# vb_cavi.R

#' Initialize VB Quantities for exDQLM VB-CAVI
#'
#' @param model An exDQLM object.
#' @param p0 Targeted quantile (e.g., 0.5 for median).
#' @param df Discount factor vector.
#' @param dim_df Dimension vector for discount factors.
#' @param gam_init Initial value for gamma.
#' @param sig_init Initial value for sigma.
#' @return List of initialized VB quantities.
initialize_vb <- function(model, p0, df, dim_df, gam_init=0.001, sig_init=1) {
  
  T <- length(model$y)
  d <- length(model$m_0)
  
  # Discount factor matrix
  df_mat <- make_df_mat(df, dim_df, d)

  # Initialize gamma and sigma VB parameters
  gam0 <- gam_init
  sig0 <- sig_init

  # Gamma, Sigma hyperparameters initialization
  vb_gamsig <- list(
    E_gam = gam0,
    V_gam = 1,
    E_sigma = sig0,
    V_sig = 1,
    E_inv_sigma = 1/sig0
    #... other precomputed expected values as needed
  )

  # Initialize auxiliary variables s_t
  vb_st <- list(
    E_sts = truncnorm::etruncnorm(a=0,b=Inf,mean=1,sd=0.1),
    E_sts2 = NULL # calculated from E_sts^2
  )
  vb_st$E_sts2 <- vb_st$E_sts^2

  # Initialize auxiliary variables u_t
  vb_ut <- list(
    E_uts = rep(1/sig0, T),
    E_inv_uts = rep(sig0, T)
  )

  # Initialize states (theta) using NDLM (to be implemented in C++)
  # Here, just a placeholder call to your future C++ function:
  theta_init <- initialize_theta_cpp(model$G_t, model$F_t, model$y, model$m_0, model$C_0, df_mat, p0)
  
  vb_theta <- list(
    exps = theta_init$exps,
    exps2 = theta_init$exps^2
  )

  list(
    df_mat = df_mat,
    vb_gamsig = vb_gamsig,
    vb_st = vb_st,
    vb_ut = vb_ut,
    vb_theta = vb_theta
  )
}

