#include <RcppArmadillo.h>
#include <cmath>
#include <limits>
#include <boost/math/tools/roots.hpp>  // Boost root-finding
#include <boost/math/distributions/normal.hpp>  // Boost for Phi function

// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;
using namespace boost::math;

// Constants for numerical stability
const double EPSILON = 1e-20;
const double INF = std::numeric_limits<double>::infinity();


// Normal CDF function (Phi) using Rcpp
inline double normal_cdf(double x) {
    return 0.5 * erfc(-x * M_SQRT1_2);
}

inline double g_gamma(double gamma) {
    return 2.0 * normal_cdf(-std::abs(gamma)) * std::exp(gamma * gamma / 2.0);
}

// Derivative of g_gamma
inline double g_gamma_prime(double gamma) {
    double phi_prime = std::exp(-0.5 * gamma * gamma) / std::sqrt(2.0 * M_PI);
    double phi_val = normal_cdf(-std::abs(gamma));
    return 2.0 * std::exp(0.5 * gamma * gamma) * (phi_prime - std::abs(gamma) * phi_val);
}

// Define a struct for solving g(gamma) - target = 0
struct GGammaRootFinder {
    double target;
    GGammaRootFinder(double t) : target(t) {}

    double operator()(double gamma) const {
        return g_gamma(gamma) - target;
    }
};

// Function to find L and U using Boost's bisection method
double find_gamma_root_boost(double target, double lower, double upper) {
    using namespace boost::math::tools;
    
    const int digits = std::numeric_limits<double>::digits; // Max precision
    eps_tolerance<double> tol(1000); // Relative tolerance of 10 bits

    uintmax_t max_iter = 100000;  // Maximum iterations allowed
    std::pair<double, double> result = bisect(GGammaRootFinder(target), lower, upper, tol, max_iter);
    
    return (result.first + result.second) / 2.0;  // Return the midpoint as the root
}

void compute_gamma_bounds(double p0, double &L, double &U) {
    double lower_bound = -100, upper_bound = 100;  // Expanded search range
    try {
        L = find_gamma_root_boost(1 - p0, lower_bound, 0);
        U = find_gamma_root_boost(p0, 0, upper_bound);
    } catch (...) {
        Rcpp::Rcout << "Failed to find valid gamma bounds for p0 = " << p0 << "\n";
        stop("Error: Unable to determine valid gamma bounds.");
    }

    if (L >= U) {
        Rcpp::Rcout << "Gamma bounds issue: L = " << L << ", U = " << U << ", p0 = " << p0 << "\n";
        stop("Error: Unable to determine valid gamma bounds.");
    }
}



// [[Rcpp::export]]
NumericVector get_gamma_bounds(double p0) {
    if (p0 <= 0 || p0 >= 1) {
        stop("Error: p0 must be in the range (0,1).");
    }

    double L, U;
    compute_gamma_bounds(p0, L, U);
    
    return NumericVector::create(Named("L") = L, Named("U") = U);
}

void validate_and_compute_parameters(double gamma, double p0, double &p, double &alpha) {
    if (p0 <= 0 || p0 >= 1) {
        stop("Error: p0 must be in the range (0,1).");
    }

    double L, U;
    compute_gamma_bounds(p0, L, U);

    // Allow gamma = 0 explicitly
    if (std::abs(gamma) < 1e-10) {
        p = p0;
        alpha = 0.0;
        return;
    }

    // Ensure gamma is in valid range
    if (gamma < L || gamma > U) {
        Rcpp::Rcout << "Invalid gamma: " << gamma << ", Allowed range: (" << L << ", " << U << ")\n";
        stop("Error: gamma is out of bounds.");
    }

    // Compute p and alpha
    double g_val = g_gamma(gamma);
    p = (gamma < 0) + (p0 - (gamma < 0)) / g_val;
    alpha = std::abs(gamma) / ((gamma > 0) - p);
}


// Compute the GAL density for standard case (mu = 0, sigma = 1)
double gal_density(double x, double p, double alpha) {
    if (alpha < 0) {
        return gal_density(-x, 1 - p, -alpha);
    }
    if (std::abs(alpha) < EPSILON) {
        // When alpha = 0, revert to AL density
        return (x >= 0) ? p * (1 - p) * std::exp(-p * x) : p * (1 - p) * std::exp((1 - p) * x);
    }

    double phi1 = normal_cdf(x / alpha - p * alpha) - normal_cdf(-p * alpha);
    double phi2 = normal_cdf((p - 1) * alpha - x / alpha * ((x / alpha) >= 0));

    double term1 = phi1 * std::exp(-p * x + 0.5 * (p * alpha) * (p * alpha)) * ((x / alpha) >= 0);
    double term2 = phi2 * std::exp(-(p - 1) * x + 0.5 * ((p - 1) * alpha) * ((p - 1) * alpha));

    return 2.0 * p * (1 - p) * (term1 + term2);
}

// [[Rcpp::export]]
double dexal(double x, double p0 = 0.5, double mu = 0.0, double sigma = 1.0, double gamma = 0.0, bool log_ = false) {
    if (sigma <= 0) {
        stop("Error: sigma must be strictly positive.");
    }

    double p, alpha;
    validate_and_compute_parameters(gamma, p0, p, alpha);

    double y = (x - mu) / sigma;
    double density = gal_density(y, p, alpha) / sigma;

    return log_ ? std::log(density) : density;
}


// Compute the GAL CDF for standard case (mu = 0, sigma = 1)
double gal_cdf(double t, double p, double alpha) {
    if (alpha < 0) {
        return 1 - gal_cdf(-t, 1 - p, -alpha);
    }
    if (std::abs(alpha) < 1e-10) {
        // When alpha = 0, revert to AL CDF
        return (t < 0) ? (p * std::exp((1 - p) * t)) : (1 - (1 - p) * std::exp(-p * t));
    }

    double phi1 = normal_cdf(-(1 - p) * alpha - t / alpha * ((t / alpha) >= 0) );
    double phi2 = normal_cdf(-p * alpha);
    double phi3 = normal_cdf(t / alpha - p * alpha);

    double term1 = 2 * p * std::exp(0.5 * (1 - p) * (1 - p) * alpha * alpha + (1 - p) * t) * phi1;
    double term2 = 2 * (1 - p) * std::exp(0.5 * p * p * alpha * alpha - p * t) * (phi2 - phi3);
    double term3 = 2 * normal_cdf(t / alpha) - 1;

    return term1 + (term2 + term3)*((t / alpha) >= 0);
}

// [[Rcpp::export]]
double pexal(double q, double p0 = 0.5, double mu = 0.0, double sigma = 1.0, double gamma = 0.0, bool lower_tail = true, bool log_p = false) {
    if (sigma <= 0) {
        stop("Error: sigma must be strictly positive.");
    }

    double p, alpha;
    validate_and_compute_parameters(gamma, p0, p, alpha);

    double y = (q - mu) / sigma;
    double cdf_value = gal_cdf(y, p, alpha);

    if (!lower_tail) {
        cdf_value = 1.0 - cdf_value;
    }
    if (log_p) {
        cdf_value = std::log(cdf_value);
    }

    return cdf_value;
}

// Bisection method to numerically solve for the quantile function
double find_quantile(double prob, double p0, double mu, double sigma, double gamma, double tol = 1e-8, int max_iter = 10000000) {
    double L = mu - 5 * sigma, U = mu + 5 * sigma;  // Initial search bounds
    double mid, cdf_mid;

    // Convert gamma to p and alpha
    double p_calc, alpha;
    validate_and_compute_parameters(gamma, p0, p_calc, alpha);

    // If alpha = 0 (AL case), use explicit AL quantile function
    if (std::abs(alpha) < EPSILON) {
        return (prob < p_calc) ? mu + sigma * std::log(prob / (p_calc)) / (1 - p_calc) :
                                 mu - sigma * std::log((1 - prob) / (1-p_calc) ) / p_calc;
    }

    // Bisection method to find inverse CDF
    for (int i = 0; i < max_iter; i++) {
        mid = (L + U) / 2.0;
        cdf_mid = gal_cdf((mid - mu) / sigma, p_calc, alpha);

        if (std::abs(cdf_mid - prob) < tol) {
            return mid;  // Solution found
        }
        if (cdf_mid < prob) {
            L = mid;
        } else {
            U = mid;
        }
    }

    Rcpp::warning("qexal: Bisection method did not converge. Try increasing `max_iter` or adjusting `tol`.");
    return NA_REAL; // Fallback return
}

// [[Rcpp::export]]
double qexal(double prob, double p0 = 0.5, double mu = 0.0, double sigma = 1.0, double gamma = 0.0, bool lower_tail = true, bool log_p = false) {
    if (sigma <= 0) {
        stop("Error: sigma must be strictly positive.");
    }
    if (prob <= 0 || prob >= 1) {
        stop("Error: prob must be in the range (0,1).");
    }

    // Adjust tail probability if needed
    if (!lower_tail) {
        prob = 1.0 - prob;
    }
    if (log_p) {
        prob = std::exp(prob);
    }

    return find_quantile(prob, p0, mu, sigma, gamma);
}
// Function to generate Half-Normal(0,1) samples
double half_normal_sample() {
    return std::abs(R::rnorm(0.0, 1.0));
}

// Function to generate AL(p, 0, 1) samples
double al_sample(double p) {
    double U = R::runif(0.0, 1.0);
    return (U < p) ? std::log(U / (p)) / (1 - p) : -std::log((1 - U) / (1-p) ) / p;
}

// [[Rcpp::export]]
NumericVector rexal(int n, double p0 = 0.5, double mu = 0.0, double sigma = 1.0, double gamma = 0.0) {
    if (sigma <= 0) {
        stop("Error: sigma must be strictly positive.");
    }
    if (n <= 0) {
        stop("Error: n must be a positive integer.");
    }

    // Validate and compute parameters
    double p, alpha;
    validate_and_compute_parameters(gamma, p0, p, alpha);

    NumericVector samples(n);

    for (int i = 0; i < n; i++) {
        double y;

        if (std::abs(alpha) < EPSILON) {
            // Case: alpha = 0 (reduce to AL)
            y = al_sample(p);
        } else {
            // Case: General GAL
            double s = half_normal_sample();
            double x =  al_sample(p);
            y = x + alpha * s;
        }

        // Apply location-scale transformation
        samples[i] = mu + sigma * y;
    }

    return samples;
}
