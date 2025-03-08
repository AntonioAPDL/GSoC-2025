# tmp_test_vb.R

library(testthat)
library(Rcpp)
library(RcppArmadillo)

source("/home/antonio/GSoC-2025/tasks/task_hard/R/exDQLM.R")
Rcpp::sourceCpp("/home/antonio/GSoC-2025/tasks/task_hard/src/exDQLM_utils.cpp")


set.seed(123)
y <- rnorm(100)  # Simulate time series data
X <- matrix(rnorm(300), 100, 3)

# Create exDQLM model object
model <- exDQLM(y, p=2, harmonics=c(1,2), period=12, X=X, transfer_function=FALSE)

# Initialize VB quantities
vb_init <- initialize_vb(model, p0=0.5, df=c(0.999,0.999,0.999), dim_df=c(2,4,3))

# Run VB loop (later)
# vb_results <- run_vb_cavi(model, vb_init, convergence_criteria)
