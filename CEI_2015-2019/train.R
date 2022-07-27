# Script for testing out timing of different train options

library(fusionModel)

scratch.dir = "/global/scratch/users/ckingdon/"
in.dir = file.path(scratch.dir, "input_fusionACS/CEI_2015-2019/")
out.dir = file.path(scratch.dir, "output_fusionACS/CEI_2015-2019/")

#------------- Prep data

# Load the training data
train.data <- read_fst(file.path(in.dir, "CEI_2015-2019_train.fst"))

# Extract variable names from the prediction data (without loading to memory)
pred.vars <- names(fst(file.path(in.dir, "CEI_2015-2019_predict.fst")))

# Identify the fusion variables
fusion.vars <- setdiff(names(train.data), c("weight", pred.vars))

#------------- Train

#------------- Run with 4 cores
start = Sys.time()
fsn.path <- train(data = train.data,
                  y = fusion.vars[1],
                  x = pred.vars,
                  file = file.path(out.dir, "CEI_2015-2019_model.fsn"),
                  weight = "weight",
                  nfolds = 0.75,
                  cores = 4,
                  hyper = list(boosting = "goss",
                               num_leaves = 2 ^ 5 - 1,
                               feature_fraction = 0.8,
                               num_iterations = 1000,
                               learning_rate = 0.1)
)
print(Sys.time() - start)

#------------- Run with 24 cores
start = Sys.time()
fsn.path <- train(data = train.data,
                  y = fusion.vars[1],
                  x = pred.vars,
                  file = file.path(out.dir, "CEI_2015-2019_model.fsn"),
                  weight = "weight",
                  nfolds = 0.75,
                  cores = 24,
                  hyper = list(boosting = "goss",
                               num_leaves = 2 ^ 5 - 1,
                               feature_fraction = 0.8,
                               num_iterations = 1000,
                               learning_rate = 0.1)
)
print(Sys.time() - start)

#------------- Run with 1 core
start = Sys.time()
fsn.path <- train(data = train.data,
                  y = fusion.vars[1],
                  x = pred.vars,
                  file = file.path(out.dir, "CEI_2015-2019_model.fsn"),
                  weight = "weight",
                  nfolds = 0.75,
                  cores = 1,
                  hyper = list(boosting = "goss",
                               num_leaves = 2 ^ 5 - 1,
                               feature_fraction = 0.8,
                               num_iterations = 1000,
                               learning_rate = 0.1)
)
print(Sys.time() - start)