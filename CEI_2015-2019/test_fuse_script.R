# script for testing/timing different calls to `fuse`

library(fusionModel)

scratch.dir = "/global/scratch/users/ckingdon/"
in.dir = file.path(scratch.dir, "input_fusionACS/CEI_2019/")

out.dir = file.path(scratch.dir, "output_fusionACS/CEI_2019/")

num.cores = as.numeric(Sys.getenv('SLURM_CPUS_ON_NODE'))

#-----

# Load the training data
train.data <- read_fst(file.path(in.dir, "CEI_2015-2019_2019_train.fst"))

# Extract variable names from the prediction data (without loading to memory)
pred.vars <- names(fst(file.path(in.dir, "CEI_2015-2019_2019_predict.fst")))

# Identify the fusion variables
fusion.vars <- setdiff(names(train.data), c("weight", pred.vars))

fusion.vars <- fusion.vars[1]

#-----

# Number of spatial implicates in 'train.data'
nsimp <- 5

# Rows in 'train.data' for just the first spatial implicate
fsimp <- seq(to = nrow(train.data), by = nsimp)

# Initial production run: restrict train.data to first spatial implicate
# Need to test more with multiple implicates
train.data <- train.data[fsimp, ]

#-----

# Train fusion model
start = Sys.time()
fsn.path <- train(data = train.data,
                  y = fusion.vars,
                  x = pred.vars,
                  file = file.path(out.dir, "CEI_2015-2019_2019_model_TEST.fsn"),
                  weight = "weight",
                  nfolds = 0.75,
                  cores = num.cores,
                  hyper = list(boosting = "goss",
                               num_leaves = 2 ^ (5) - 1,
                               min_data_in_leaf = unique(round(pmax(10, length(fsimp) * 0.0005 * c(1)))),
                               feature_fraction = 0.8,
                               num_iterations = 250,
                               learning_rate = 0.1)
)
print(Sys.time() - start)

#----

# Load the prediction data
pred.data <- read_fst(file.path(in.dir, "CEI_2015-2019_2019_predict.fst"))

start = Sys.time()
sim1 <- fuse(data = pred.data,
             file = fsn.path,
             k = 10,
             cores = num.cores)

print(Sys.time() - start)
rm(sim1)
gc()
pred.data <- bind_rows(pred.data, pred.data)
start = Sys.time()
sim2 <- fuse(data = pred.data,
             file = fsn.path,
             k = 10,
             cores = num.cores)

print(Sys.time() - start)
rm(sim2)
gc()
pred.data <- bind_rows(pred.data, pred.data)
start = Sys.time()
sim3 <- fuse(data = pred.data,
             file = fsn.path,
             k = 10,
             cores = num.cores)
print(Sys.time() - start)
