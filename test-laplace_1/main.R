library(posteriordb)
library(rstan)

# MeteInfo
R <- "1"
MODEL_NAME <- sprintf("test-laplace_%s", R)

# Add Data
Sys.setenv(PDB_PATH = "../posteriordb")
pdbl <- pdb_local()

x_data <- list(name = MODEL_NAME,
          keywords = c("test_laplace"),
          title = sprintf("A Test Data for the Laplacian %s Model", R),
          description = sprintf("The data contain data for Laplacian %s Model.", R),
          urls = NULL,
          references = NULL,
          added_date = Sys.Date(),
          added_by = "Congye Wang")

di <- as.pdb_data_info(x_data)
laplace <- list(N = as.integer(2), r = as.double(R))
dat <- as.pdb_data(laplace, info = di)
write_pdb(dat, pdbl, overwrite = TRUE)

# Add model
x_model <- list(name = MODEL_NAME,
                keywords = c("test_laplace"),
                title = sprintf("A Test Data for the Laplacian %s Model", R),
                description = sprintf("The data contain data for Laplacian %s Model.", R),
                urls = NULL,
                framework = "stan",
                references = NULL,
                added_by = "Congye Wang",
                added_date = Sys.Date())

mi <- as.pdb_model_info(x_model)
smc <- "
data {
  int<lower=1> N;
  real r;
}

parameters {
  vector[N] x;
}

model {
  target += -norm2(x)^r;
}
"
mc <- as.model_code(smc, info = mi, framework = "stan")
write_pdb(mc, pdbl)

# Add Posterior
x_posterior <- list(pdb_model_code = mc,
          pdb_data = dat,
          keywords = c("test_laplace"),
          urls = NULL,
          references = NULL,
          dimensions = list("x" = 2),
          reference_posterior_name = sprintf("%s-%s", MODEL_NAME, MODEL_NAME),
          added_date = Sys.Date(),
          added_by = "Congye Wang")
po <- as.pdb_posterior(x_posterior)
write_pdb(po, pdbl)

# Add Posterior Reference Draws
po <- posterior(sprintf("%s-%s", MODEL_NAME, MODEL_NAME), pdbl)
po$dimensions <- list("x" = 2)
## Setup reference posterior info ----
x_draw <- list(name = posterior_name(po),
          inference = list(method = "stan_sampling",
                           method_arguments = list(chains = 10,
                                                   iter = 20000,
                                                   warmup = 10000,
                                                   thin = 10,
                                                   seed = 4711,
                                                   control = list(adapt_delta = 0.92))),
          diagnostics = NULL,
          checks_made = NULL,
          comments = sprintf("This is a test reference posterior for the Laplacian %s Model", R),
          added_by = "Congye Wang",
          added_date = Sys.Date(),
          versions = NULL)

rpi <- as.pdb_reference_posterior_info(x_draw)
rp <- compute_reference_posterior_draws(rpi, pdbl)
rp <- check_reference_posterior_draws(x = rp)
write_pdb(rp, pdbl, overwrite = TRUE)

# Check
check_pdb_posterior(po)
