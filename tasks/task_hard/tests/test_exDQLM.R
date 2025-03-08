library(testthat)
library(Rcpp)

source("/home/antonio/GSoC-2025/tasks/task_hard/R/exDQLM.R")
Rcpp::sourceCpp("/home/antonio/GSoC-2025/tasks/task_hard/src/exDQLM_utils.cpp")

test_that("exDQLM constructor works correctly", {
  y <- rnorm(100)  # Simulated time series
  X <- matrix(rnorm(100 * 3), 100, 3)  # Simulated regressors
  
  model <- exDQLM(y, p = 2, harmonics = c(1, 2), period = 12, 
                  X = X, transfer_function = FALSE)
  
  expect_s3_class(model, "exDQLM")  # Check if it returns an exDQLM object
  expect_equal(length(model$y), 100)  # Ensure correct data length
  
  # Check F_t and G_t dimensions
  expect_equal(dim(model$F_t), c(2 + 4 + 3, 100))  # p + 2H + K x T
  expect_equal(dim(model$G_t), c(2 + 4 + 3, 2 + 4 + 3, 100))  # dxdxT

  # Check prior mean and covariance dimensions
  expect_equal(length(model$m_0), 2 + 4 + 3)  # p + 2H + K
  expect_equal(dim(model$C_0), c(2 + 4 + 3, 2 + 4 + 3))  # dxd
  
  # Check if C_0 has the correct default diagonal values (1000)
  expect_true(all(diag(model$C_0) == 1000))
})
