# Task 1: Extended Asymmetric Laplace (exAL) Distribution

This folder contains the implementation of the **Extended Asymmetric Laplace (exAL)** distribution using **C++** and **Rcpp**.

## 📌 Implemented Functions
We will implement the following functions for the exAL distribution:
- ****: Density function.
- ****: CDF function.
- ****: Quantile function.
- ****: Random sampling function.

## 📂 Directory Structure
The implementation will follow an **organized directory structure**:
- **** → C++ implementation of exAL functions.
- **** → R wrapper functions to expose C++ code.
- **** → Unit tests for validating correctness.
- **** → R documentation for function usage.
- **** → Detailed examples and use cases.

## 🔧 Next Steps
1. Implement the core C++ functions ( and ).
2. Expose functions to R using **Rcpp**.
3. Validate against **analytical properties** and existing R implementations.
4. Write **unit tests** to ensure numerical stability.

---
📌 **References**  
- Yan and Kottas (2017) - "A Bayesian nonparametric mixture modeling framework for quantile regression"  
- Rcpp Documentation - [CRAN Rcpp](https://cran.r-project.org/web/packages/Rcpp/index.html)  

