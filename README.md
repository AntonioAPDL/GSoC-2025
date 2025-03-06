# 🚀 GSoC 2025: Enhancing exDQLM

Welcome to the official repository for the **Google Summer of Code (GSoC) 2025** project aimed at enhancing the **exDQLM** package. This repository will house all proposals, development progress, and documentation related to the project.

## 📌 Project Overview

The **exDQLM** package provides a Bayesian framework for **Dynamic Quantile Regression** using state-space models. This GSoC project will enhance the package by improving computational efficiency, incorporating **Variational Bayes (VB)**, extending it for **multivariate time series**, and ensuring compatibility with other R Bayesian packages.

- **Project Title:** TBD
- **Short Title:** TBD
- **Primary Goal:** Improve the exDQLM. 

## 📂 Repository Contents

| Folder/File | Description |
|------------|-------------|
| `tasks/` | Contains finished tasks |
| `proposals/` | Contains drafts and final versions of the GSoC proposal. |
| `README.md` | This file, providing an overview of the project. |

## 🔗 Important Links

- 📄 **Original exDQLM Paper:** [Technical Report UCSC-SOE-21-10](https://tr.soe.ucsc.edu/sites/default/files/technical-reports/UCSC-SOE-21-10.pdf)
- 📦 **CRAN Package:** [exDQLM on CRAN](https://cran.r-project.org/web/packages/exdqlm/index.html)
- 🌐 **GSoC Official Page:** [Google Summer of Code](https://summerofcode.withgoogle.com/)

## 📅 GSoC 2025 Timeline

| Phase | Dates | Description |
|-------|-------|-------------|
| **Mentoring Org Applications** | Jan 27 – Feb 11, 2025 | Organizations apply to participate. |
| **Organizations Announced** | Feb 27, 2025 | Google publishes accepted organizations. |
| **Project Advertisement** | By March 1, 2025 | The R Project Wiki includes project details. |
| **Contributor Applications** | March 24 – April 8, 2025 | Submission of proposals. |
| **Proposal Review** | April 22, 2025 | Google and mentors evaluate submissions. |
| **Accepted Contributors Announced** | May 8, 2025 | Successful contributors are selected. |
| **Community Bonding Period** | May 8 – June 1, 2025 | Refining project goals and community engagement. |
| **Coding Phase 1** | June 2 – June 17, 2025 | Setting up the repository and initial development. |
| **Coding Phase 2** | June 18 – July 15, 2025 | Feature expansion and testing. |
| **Midterm Evaluations** | July 14 – 18, 2025 | Progress review with mentors. |
| **Final Coding Phase** | July 16 – Aug 19, 2025 | Final optimizations and documentation. |
| **Final Evaluations** | Sept 1 – 8, 2025 | Mentors submit final assessments. |

## 🎯 Objectives of the Project

The key improvements planned for **exDQLM** include:

-  **Implementing Variational Bayes (VB)** for faster inference.
-  **Extending support for multivariate time series quantile modeling.**
-  **Improving computational performance** via C++ (`Rcpp` & `RcppParallel`).
-  **Enhancing compatibility** with `rstan`, `bayesplot`, and other R Bayesian packages.
-  **Developing better visualization tools** for model diagnostics.
-  **Ensuring efficient posterior predictive quantile synthesis (PPQS)**.

## 🏆 Mentors

This project is supported by the **R Project** under GSoC 2025.

| Mentor | Institution | Role |
|--------|------------|------|
| **Rebecca Killick** | Lancaster University, UK | Evaluating Mentor |
| **Raquel Barata** | Penn State, USA | Co-Mentor |

## 🏗 Next Steps

| Task | Deadline | Status |
|------|----------|--------|
| Confirm mentors | ✅ Feb 14, 2025 | Completed |
| Publish one-page project summary on R Project Wiki | March 1, 2025 | Pending |
| Submit full proposal to Google | March 24 – April 8, 2025 | Pending |
| Proposal Review by Google & Mentors | April 22, 2025 | Pending |
| Officially begin the project | May 8, 2025 | Pending |


## 📬 Contact

If you have any questions or suggestions, feel free to reach out:

- **Antonio Aguirre** (Contributor) – jaguir26@ucsc.edu
- **Rebecca Killick** (Mentor) – r.killick@lancaster.ac.uk
- **Raquel Barata** (Mentor) – rxb875@psu.edu

---

