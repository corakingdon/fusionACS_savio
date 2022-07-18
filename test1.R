# Test script
# to see if workflow runs on Savio
# Read in data, subset, and save 

library(dplyr)

scratch.dir = "/global/scratch/users/ckingdon/"
# scratch.dir = "C:/Users/Cora/SC2/repos/RECS-ACS/"
data.path = paste0(scratch.dir, "data.RDS")
data = readRDS(data.path)

sample_data = slice_sample(data$RECS_2015, n = 1e3)
saveRDS(sample_data, paste0(scratch.dir, "test_sample.RDS"))
