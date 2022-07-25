# To run on Savio

library(fusionModel)
library(fst)

scratch.dir = "/global/scratch/users/ckingdon/"
out.dir = file.path(scratch.dir, "output_fusionACS/RECS-ACS/")  

data.path = file.path(scratch.dir, "fusionACS_input/RECS-ACS/data.RDS")
data = readRDS(data.path)

num.cores = as.numeric(Sys.getenv('SLURM_CPUS_ON_NODE'))

#------------- Prepare variables -----------------------------------------------

# Select desired fusion variables
fusion.vars <- attr(data, "fusion.vars")

# Predictor variables
# This is just a fancy way to pull the predictor variables from 'data' attributes
pred.vars <- unlist(map(c("harmonized.vars", "location.vars", "spatial.vars"), ~ attr(data, .x)))

# Get fusion sequence and blocking
# Can sample 'data' if training dataset is too large/slow
# fsequence <- blockchain(data = slice_sample(data$RECS_2015, n = 10e3),
#                         y = fusion.vars,
#                         x = pred.vars,
#                         delta = 0,  # Prevent blocking
#                         weight = "weight",
#                         cores = num.cores)

#------------- Train fusion model ----------------------------------------------

file.fsn <- train(data = data$RECS_2015,
                  # y = fsequence,
                  y = fusion.vars,
                  x = pred.vars,
                  file = "production/v2/RECS/2015/RECS_2015.fsn",
                  weight = "weight",
                  nfolds = 5,
                  cores = num.cores,
                  hyper = list(boosting = "gbdt",
                               feature_fraction = 0.8,
                               num_iterations = 9999,
                               learning_rate = 0.05)
)

#------------- Fuse variables to ACS for multiple implicates -------------------

# Optimal settings for 'k' and 'max_dist' are unknown at moment -- using default values
sim <- fuseM(data = data$ACS_2015,
             file = file.fsn,
             k = 5,
             cores = num.cores,
             M = 10)  # Just try 10 implicates for now...

# Save simulation results to disk
fst::write_fst(x = sim,
               path = file.path(out.dir, "RECS_2015-ACS_2015.fst"),
               compress = 100)