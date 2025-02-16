library(posteriordb)
library(rstan)

# MeteInfo
MODEL_NAME <- "test-neals_funnel"

# Add Data
Sys.setenv(PDB_PATH = "../posteriordb")
pdbl <- pdb_local()

x_data <- list(name = MODEL_NAME,
               keywords = c("test_neals_funnel"),
               title = "A Test Data for Neal's funnel Model",
               description = "The data contain data for Neal's funnel Model.",
               urls = NULL,
               references = NULL,
               added_date = Sys.Date(),
               added_by = "Congye Wang")

di <- as.pdb_data_info(x_data)
neals_funnel <- list()
dat <- as.pdb_data(neals_funnel, info = di)
write_pdb(dat, pdbl, overwrite = TRUE)

# Add model
x_model <- list(name = MODEL_NAME,
                keywords = c("test_neals_funnel"),
                title = "A Test Data for Neal's funnel Model",
                description = "The data contain data for Neal's funnel Model.",
                urls = NULL,
                framework = "stan",
                references = NULL,
                added_by = "Congye Wang",
                added_date = Sys.Date())

mi <- as.pdb_model_info(x_model)
smc <- "
parameters {
  real y_raw;
  real x_raw;
}
transformed parameters {
  real y;
  real x;

  y = 3.0 * y_raw;
  x = exp(y/2) * x_raw;
}
model {
  y_raw ~ std_normal();
  x_raw ~ std_normal();
}
"
mc <- as.model_code(smc, info = mi, framework = "stan")
write_pdb(mc, pdbl)

# Add Posterior
x_posterior <- list(pdb_model_code = mc,
                    pdb_data = dat,
                    keywords = c("test_neals_funnel"),
                    urls = NULL,
                    references = NULL,
                    dimensions = list("x" = 1, "y" = 1),
                    reference_posterior_name = sprintf("%s-%s", MODEL_NAME, MODEL_NAME),
                    added_date = Sys.Date(),
                    added_by = "Congye Wang")
po <- as.pdb_posterior(x_posterior)
write_pdb(po, pdbl)

# Add Posterior Reference Draws
po <- posterior(sprintf("%s-%s", MODEL_NAME, MODEL_NAME), pdbl)
po$dimensions <- list("x" = 1, "y" = 1)
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
               comments = "This is a test reference posterior for Neal's funnel Model",
               added_by = "Congye Wang",
               added_date = Sys.Date(),
               versions = NULL)

rpi <- as.pdb_reference_posterior_info(x_draw)
rp <- compute_reference_posterior_draws(rpi, pdbl)
rp <- check_reference_posterior_draws(x = rp)
write_pdb(rp, pdbl, overwrite = TRUE)

# Check
check_pdb_posterior(po)
