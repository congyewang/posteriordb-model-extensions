functions {
    /** @addtogroup skew_generalized_t Skew Generalized T distribution functions
    *
    * From the sgt R package
    * Carter Davis (2015). sgt: Skewed Generalized T Distribution Tree. R package version 2.0.
    * https://CRAN.R-project.org/package=sgt
    *
    * The Skewed Generalized T Distribution is a univariate 5-parameter distribution introuced
    * by Theodossiou (1998) and known for its extreme flexibility. Special and limiting cases of
    * the SGT distribution include the skewed generalized error distribution, the generalized t
    * distribution introduced by McDonald and Newey (1988), the skewed t proposed by Hansen (1994),
    * the skewed Laplace distribution, the generalized error distribution (also known as the
    * generalized normal distribution), the skewed normal distribution, the student t distribution,
    * the skewed Cauchy distribution, the Laplace distribution, the uniform distribution, the
    * normal distribution, and the Cauchy distribution.
    *
    * Hansen, B. E., 1994, Autoregressive Conditional Density Estimation, International Economic
    * Review 35, 705-730.
    *
    * Hansen, C., J. B. McDonald, and W. K. Newey, 2010, Instrumental Variables Estimation with
    * Flexible Distribution sigma  Journal of Business and Economic Statistics 28, 13-25.
    *
    * McDonald, J. B. and W. K. Newey, 1988, Partially Adaptive Estimation of Regression Models
    * via the Generalized t Distribution, Econometric Theory 4, 428-457.
    *
    * Theodossiou, Panayioti sigma  1998, Financial Data and the Skewed Generalized T
    * Distribution, Management Science 44, 1650-166
    *
    * @include \distribution\skew_generalized_t.stanfunctions
    *
    * \ingroup univariate
    *  @{ */

    /** Skew Generalized T Rescale Sigma to be Variance
    *
    * @copyright Sean Pinkney, 2021
    * @author Sean Pinkney
    * @param sigma Real \f$\in (0, \infty)\f$ scale parameter
    * @param lambda Real \f$-1 < \lambda < 1\f$
    * @param p Real \f$\in (0, \infty)\f$ kurtosis parameter
    * @param q Real \f$\in (0, \infty)\f$ kurtosis parameter
    * @throws reject if \f$ pq \leq 2 \f$
    * @return rescaled sigma
    */
    real variance_adjusted_sgt(real sigma, real lambda, real p, real q) {
    if (p * q <= 2)
        reject("p * q must be > 2 found p * q = ", p * q);

    if (is_inf(q))
        return sigma
            * inv_sqrt((pi() * (1 + 3 * lambda ^ 2) * tgamma(3.0 / p)
                        - 16 ^ (1.0 / p) * lambda ^ 2 * (tgamma(1.0 / 2 + 1.0 / p)) ^ 2
                            * tgamma(1.0 / p))
                        / (pi() * tgamma(1.0 / p)));

    return sigma
            / (q ^ (1.0 / p)
                * sqrt((3 * lambda ^ 2 + 1) * (beta(3.0 / p, q - 2.0 / p) / beta(1.0 / p, q))
                    - 4 * lambda ^ 2 * (beta(2.0 / p, q - 1.0 / p) / beta(1.0 / p, q)) ^ 2));
    }

    /** Skew Generalized T Center Mean
    *
    * Centers the mean around mu, otherwise mu is the mode.
    *
    * @copyright Sean Pinkney, 2021
    * @author Sean Pinkney
    * @param sigma Real \f$\in (0, \infty)\f$ scale parameter
    * @param lambda Real \f$-1 < \lambda < 1\f$
    * @param p Real \f$\in (0, \infty)\f$ kurtosis parameter
    * @param q Real \f$\in (0, \infty)\f$ kurtosis parameter
    * @throws reject if \f$ pq \leq 1 \f$
    * @return rescaled x
    */
    vector mean_centered_sgt(vector x, real sigma, real lambda, real p, real q) {
    if (p * q <= 1)
        reject("p * q must be > 1 found p * q = ", p * q);

    if (is_inf(q))
        return x + (2 ^ (2.0 / p) * sigma * lambda * tgamma(1.0 / 2 + 1.0 / p)) / sqrt(pi());

    return x
            + (2 * sigma * lambda * q ^ (1.0 / p) * beta(2 / p, q - 1.0 / p))
            / beta(1.0 / p, q);
    }

    real mean_centered_sgt(real x, real sigma, real lambda, real p, real q) {
    if (p * q <= 1)
        reject("p * q must be > 1 found p * q = ", p * q);

    if (is_inf(q))
        return x + (2 ^ (2.0 / p) * sigma * lambda * tgamma(1.0 / 2 + 1.0 / p)) / sqrt(pi());

    return x
            + (2 * sigma * lambda * q ^ (1.0 / p) * beta(2 / p, q - 1.0 / p))
            / beta(1.0 / p, q);
    }

    real mean_centered_sgt(real x, real sigma, real lambda, real q) {
    if (q <= 1)
        reject("q must be > 1 found q = ", q);

    if (is_inf(q))
        return x + (4 * sigma * lambda * tgamma(1.0 / 2 + 1.0)) / sqrt(pi());

    return x + (2 * sigma * lambda * q * beta(2, q - 1.0)) / beta(1.0, q);
    }

    /**
    * The Skewed Generalized T distribution is defined as
    *
    * \f[
    * f_{SGT}(x; \mu, \sigma, \lambda, p, q) = \frac{p}{2 v \sigma  q^{1/p} B(\frac{1}{p},q)
    * \left(\frac{| x-\mu + m |^p}{q (v \sigma)^p (\lambda sign(x-\mu + m)+1)^p}+1\right)^{\frac{1}{p}+q}}
    * \f]
    * where  \f$B\f$ is the beta function, \f$ \mu \f$ is the location parameter, \f$\sigma > 0\f$
    * is the scale parameter, \f$-1 < \lambda < 1\f$ is the skewness parameter, and \f$p > 0\f$ and
    * \f$q > 0\f$ are the parameters that control the kurtosis. \f$m\f$ and \f$v\f$ are not parameter sigma 
    * but functions of the other parameters that are used here to scale or shift the distribution
    * appropriately to match the various parameterizations of this distribution.
    *
    * In the original parameterization Theodossiou of the skewed generalized t distribution,
    * \f[
    * m = \frac{2 v \sigma \lambda q^{\frac{1}{p}} B(\frac{2}{p},q-\frac{1}{p})}{B(\frac{1}{p},q)}
    * \f]
    * and
    * \f[
    * v = \frac{q^{-\frac{1}{p}}}{\sqrt{ (3 \lambda^2 + 1)
    *  \frac{ B ( \frac{3}{p}, q - \frac{2}{p} )}{B (\frac{1}{p}, q )}
    *  -4 \lambda^2 \frac{B ( \frac{2}{p}, q - \frac{1}{p} )^2}{ B (\frac{1}{p}, q )^2}}}.
    * \f]
    *
    * @copyright Sean Pinkney, 2021
    * @author Sean Pinkney
    * @param x Vector
    * @param mu Real
    * @param sigma Real \f$\in (0, \infty)\f$ scale parameter
    * @param lambda Real \f$-1 < \lambda < 1\f$
    * @param p Real \f$\in (0, \infty)\f$ kurtosis parameter
    * @param q Real \f$\in (0, \infty)\f$ kurtosis parameter
    * @return log probability
    */
    real skew_generalized_t_lpdf(vector x, real mu, real sigma, real lambda, real p, real q) {
    if (sigma <= 0)
        reject("sigma must be > 0 found sigma = ", sigma);

    if (lambda >= 1 || lambda <= -1)
        reject("lambda must be between (-1, 1) found lambda = ", lambda);

    if (p <= 0)
        reject("p must be > 0 found p = ", p);

    if (q <= 0)
        reject("q must be > 0 found q = ", q);

    int N = num_elements(x);
    real out = 0;
    real sigma_adj = variance_adjusted_sgt(sigma, lambda, p, q);

    if (is_inf(q) && is_inf(p))
        return uniform_lpdf(x | mu - sigma_adj, mu + sigma_adj);

    vector[N] r = mean_centered_sgt(x, sigma_adj, lambda, p, q) - mu;
    vector[N] s;

    for (n in 1 : N)
        s[n] = r[n] < 0 ? -1 : 1;

    if (is_inf(q) && !is_inf(p)) {
        out = sum((abs(r) ./ (sigma_adj * (1 + lambda * s))) ^ p);
        return log(p) - log(2) - log(sigma_adj) - lgamma(1.0 / p) - out;
    } else {
        out = sum(log1p(abs(r) ^ p ./ (q * sigma_adj ^ p * pow(1 + lambda * s, p))));
    }

    return N * (log(p) - log2() - log(sigma_adj) - log(q) / p - lbeta(1.0 / p, q))
            - (1.0 / p + q) * out;
    }

    /**
    * The Skewed T distribution
    *
    * @copyright Sean Pinkney, 2021
    * @author Sean Pinkney
    * @param x Vector
    * @param mu Real
    * @param sigma Real \f$\in (0, \infty)\f$ scale parameter
    * @param lambda Real \f$-1 < \lambda < 1\f$
    * @param q Real \f$\in (0, \infty)\f$ kurtosis parameter
    * @return log probability
    */
    real skew_t_lpdf(vector x, real mu, real sigma, real lambda, real q) {
    return skew_generalized_t_lpdf(x | mu, sigma, lambda, 2, q);
    }

    /**
    * The Generalized T distribution
    *
    * @copyright Sean Pinkney, 2021
    * @author Sean Pinkney
    * @param x Vector
    * @param mu Real
    * @param sigma Real \f$\in (0, \infty)\f$ scale parameter
    * @param q Real \f$\in (0, \infty)\f$ kurtosis parameter
    * @return log probability
    */
    real generalized_t_lpdf(vector x, real mu, real sigma, real p, real q) {
    return skew_generalized_t_lpdf(x | mu, sigma, 0, p, q);
    }

    /** Skew Generalized T log cumulative density function
    *
    * @copyright Sean Pinkney, 2021
    * @author Sean Pinkney
    * @param x Real
    * @param mu Real
    * @param sigma Real \f$\in (0, \infty)\f$ scale parameter
    * @param lambda Real \f$-1 < \lambda < 1\f$
    * @param p Real \f$\in (0, \infty)\f$ kurtosis parameter
    * @param q Real \f$\in (0, \infty)\f$ kurtosis parameter
    * @return log probability
    */
    real skew_generalized_t_lcdf(real x, real mu, real sigma, real lambda, real p, real q) {
    if (sigma <= 0)
        reject("sigma must be > 0 found sigma = ", sigma);

    if (lambda >= 1 || lambda <= -1)
        reject("lambda must be between (-1, 1) found lambda = ", sigma);

    if (p <= 0)
        reject("p must be > 0 found p = ", p);

    if (q <= 0)
        reject("q must be > 0 found q = ", q);

    if (is_inf(x) && x < 0)
        return 0;

    if (is_inf(x) && x > 0)
        return 1;

    real sigma_adj = variance_adjusted_sgt(sigma, lambda, p, q);
    real x_cent = mean_centered_sgt(x, sigma_adj, lambda, p, q);
    real r = x_cent - mu;
    real lambda_new;
    real r_new;

    if (r > 0) {
        lambda_new = -lambda;
        r_new = -r;
    } else {
        lambda_new = lambda;
        r_new = r;
    }

    if (!is_inf(p) && is_inf(q) && !is_inf(x))
        return log_sum_exp([log1m(lambda_new) + log2(),
                            log(lambda_new - 1) + log2()
                            + beta_lcdf((r_new / (sigma * (1 + lambda_new))) ^ p | p, 1)]);
    if (is_inf(p) && !is_inf(x))
        return uniform_lcdf(x | mu, sigma);

    if (is_inf(x) && x < 0)
        return 0;

    if (is_inf(x) && x > 0)
        return 1;

    return log_sum_exp([log1m(lambda_new) + log2(),
                        log(lambda_new - 1) + log2()
                        + beta_lcdf(1.0
                                    / (1 + q * (sigma * (1 - lambda_new) / (-r_new)) ^ p) | 1.0
                                                                        / p, q)]);
    }

    /** @} */
}

data {
    int<lower=0> N;

    real mu;
    real<lower=0> sigma;
    real<lower=-1, upper=1> lambda;
    real<lower=0> p;
    real<lower=0> q;
}

parameters {
    vector[N] x;
}

model {
    target += skew_generalized_t_lpdf(x | mu, sigma, lambda, p, q);
}
