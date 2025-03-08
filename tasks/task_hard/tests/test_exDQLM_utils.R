library(testthat)
library(Rcpp)
library(RcppArmadillo)

source("/home/antonio/GSoC-2025/tasks/task_hard/R/exDQLM.R")
Rcpp::sourceCpp("/home/antonio/GSoC-2025/tasks/task_hard/src/exDQLM_utils.cpp")


test_that("generate_trend_matrices works correctly", {
  p <- 2
  T <- 10
  G_trend <- generate_trend_matrices(p, T)
  
  expect_equal(dim(G_trend), c(p, p, T)) # Check dimensions
  expect_true(all(G_trend[1, 2, ] == 1)) # Check subdiagonal entries
})

test_that("generate_trend_observations works correctly", {
  p <- 3
  T <- 5
  F_trend <- generate_trend_observations(p, T)
  
  expect_equal(dim(F_trend), c(p, T))
  expect_true(all(F_trend[1, ] == 1))  # First row should be all ones
})

test_that("generate_seasonal_matrices works correctly", {
  harmonics <- c(1, 2)
  period <- 12
  T <- 10
  G_season <- generate_seasonal_matrices(harmonics, period, T)
  
  expect_equal(dim(G_season), c(4, 4, T)) # 2 harmonics → 4x4 matrices
})

test_that("generate_seasonal_observations works correctly", {
  H <- 2
  T <- 6
  F_season <- generate_seasonal_observations(H, T)
  
  expect_equal(dim(F_season), c(2 * H, T))
  expect_true(all(F_season[seq(1, 2 * H, by = 2), ] == 1))
})

test_that("generate_regression_matrices works correctly", {
  K <- 3
  T <- 7
  G_regress <- generate_regression_matrices(K, T)
  
  expect_equal(dim(G_regress), c(K, K, T))
  expect_true(all(diag(G_regress[, , 1]) == 1)) # Identity matrix
})

test_that("generate_regression_observations works correctly", {
  X <- matrix(runif(20), nrow = 10, ncol = 2)
  F_regress <- generate_regression_observations(X)
  
  expect_equal(dim(F_regress), c(2, 10)) # Transposed dimensions
})

test_that("generate_transfer_matrices works correctly", {
  lambda <- 0.8
  X <- matrix(runif(30), nrow = 10, ncol = 3)
  G_transfer <- generate_transfer_matrices(lambda, X)
  
  expect_equal(dim(G_transfer), c(4, 4, 10)) # (K+1)x(K+1)xT
  expect_equal(G_transfer[1, 1, 1], lambda)
})

test_that("generate_transfer_observations works correctly", {
  K <- 3
  T <- 5
  F_transfer <- generate_transfer_observations(K, T)
  
  expect_equal(dim(F_transfer), c(K + 1, T))
  expect_true(all(F_transfer[1, ] == 1))
})

test_that("generate_full_evolution_matrices works correctly", {
  p <- 2
  harmonics <- c(1, 2)
  period <- 12
  K <- 3
  transfer_function <- FALSE
  lambda <- 0.8
  X <- matrix(runif(30), nrow = 10, ncol = 3)
  
  G_full <- generate_full_evolution_matrices(p, harmonics, period, K, transfer_function, lambda, X)
  
  d <- p + 2 * length(harmonics) + K
  expect_equal(dim(G_full), c(d, d, 10))  # Final dimension check
})

test_that("generate_full_observation_vectors works correctly", {
  p <- 2
  H <- 2
  K <- 3
  T <- 10
  X <- matrix(runif(T * K), nrow = T, ncol = K)
  transfer_function <- FALSE
  
  F_full <- generate_full_observation_vectors(p, H, K, transfer_function, X)
  
  expect_equal(dim(F_full), c(p + 2 * H + K, T))  # Check correct concatenation
})

test_that("generate_full_m0 works correctly", {
  p <- 2
  H <- 2
  K <- 3
  transfer_function <- FALSE
  
  m0_full <- generate_full_m0(p, H, K, transfer_function)
  
  expect_equal(length(m0_full), p + 2 * H + K)
  expect_true(all(m0_full == 0))  # Default is zero
})

test_that("generate_full_C0 works correctly", {
  p <- 2
  H <- 2
  K <- 3
  transfer_function <- FALSE
  
  C0_full <- generate_full_C0(p, H, K, transfer_function)
  
  d <- p + 2 * H + K
  expect_equal(dim(C0_full), c(d, d))  # Now expecting a 2D matrix
  expect_true(all(diag(C0_full) == 1000))  # Diagonal elements should be 1000
})

test_that("Discount Factor Matrix is correct", {
  df <- c(0.9, 0.8, 0.2)
  dim.df <- c(2, 4, 1)
  n <- 7
  
  df_mat <- make_discount_factor_matrix(df, dim.df, n)
  
  expect_equal(dim(df_mat), c(7, 7))
  
  expect_true(all(diag(df_mat)[1:2] == (1 - 0.9)/0.9))
  expect_true(all(diag(df_mat)[3:6] == (1 - 0.8)/0.8))
  expect_true(diag(df_mat)[7] == (1 - 0.2)/0.2)
  
  expect_true(all(df_mat[upper.tri(df_mat)] == 0))
  expect_true(all(df_mat[lower.tri(df_mat)] == 0))
})