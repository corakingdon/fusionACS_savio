library(fusionModel)
library(fst)

#------------- Savio settings
# num.cores = as.numeric(Sys.getenv('SLURM_CPUS_ON_NODE'))
num.cores = 4
scratch.dir = "/global/scratch/users/ckingdon/"
out.dir = file.path(scratch.dir, "output_fusionACS/RECS-ACS/")
data.path = file.path(scratch.dir, "fusionACS_input/RECS-ACS/data.RDS")

# ------------ local settings
# num.cores = 1
# scratch.dir = "./"
# out.dir = "./"
# data.path = "data.RDS"


#------------- Prepare variables -----------------------------------------------

data = readRDS(data.path)

# Select desired fusion variables
fusion.vars <- attr(data, "fusion.vars")

# Predictor variables
# This is just a fancy way to pull the predictor variables from 'data' attributes
pred.vars <- unlist(map(c("harmonized.vars", "location.vars", "spatial.vars"), ~ attr(data, .x)))


#------------- Train fusion model ----------------------------------------------

start = Sys.time()
file.fsn <- train(data = data$RECS_2015,
                  # y = fsequence,
                  y = fusion.vars,
                  x = pred.vars,
                  file = "production/v2/RECS/2015/RECS_2015.fsn",
                  weight = "weight",
                  nfolds = 5,
                  cores = num.cores,
                  # hyper = NULL
                  hyper = list(boosting = "gbdt",
                               feature_fraction = 0.8,
                               num_iterations = 9999,
                               learning_rate = 0.05)
)
print(Sys.time() - start)


