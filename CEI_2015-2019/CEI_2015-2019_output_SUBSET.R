# A script for running the pipeline with online a subset of the data.
# a smaller/faster run for testing and troubleshooting

library(fusionModel)

scratch.dir = "/global/scratch/users/ckingdon/"
in.dir = file.path(scratch.dir, "input_fusionACS/CEI_2015-2019/")

out.dir = file.path(scratch.dir, "output_fusionACS/CEI_2015-2019_SUBSET/")

num.cores = 1

#-----

# Load the training data
train.data <- read_fst(file.path(in.dir, "CEI_2015-2019_train.fst"))

# Extract variable names from the prediction data (without loading to memory)
pred.vars <- names(fst(file.path(in.dir, "CEI_2015-2019_predict.fst")))
pred.vars = sample(pred.vars, 20) # subset for smaller/faster run

# Identify the fusion variables
fusion.vars <- setdiff(names(train.data), c("weight", pred.vars))
fusion.vars = sample(fusion.vars, 5) # subset for faster/faster run

#-----

# Get fusion sequence and blocking
fchain <- blockchain(data = train.data,
                     y = fusion.vars,
                     x = pred.vars,
                     delta = 0.01,
                     maxsize = 3,
                     weight = "weight",
                     nfolds = 5,
                     fraction = 0.1, # for smaller/faster run
                     cores = num.cores)

#-----

# Train fusion model
fsn.path <- train(data = train.data,
                  y = fchain,
                  x = pred.vars,
                  file = file.path(out.dir, "CEI_2015-2019_model.fsn"),
                  weight = "weight",
                  nfolds = 0.75, # for smaller/faster run
                  cores = 0,
                  hyper = NULL # for smaller/faster run
)

#----

# Remove the training data
rm(train.data)

# Load the prediction data
pred.data <- read_fst(file.path(in.dir, "CEI_2015-2019_predict.fst"))

# Fuse multiple implicates to ACS
# Optimal settings for 'k' and 'max_dist' are unknown at moment -- using default values
sim <- fuseM(data = pred.data[1:5e4, ], # for smaller/faster run
             file = fsn.path,
             k = 10,
             M = 2, # for smaller/faster run
             cores = num.cores)

# Save result as .fst
fst::write_fst(x = sim,
               path = file.path(out.dir, "CEI_2015-2019_fused.fst"),
               compress = 100)

# Cleanup
rm(sim, pred.data)