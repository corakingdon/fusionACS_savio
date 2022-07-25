library(fusionData)
library(fusionModel)

#-----

# Prepare and assemble data inputs
prep <- prepare(donor = "RECS_2015",
                recipient = "ACS_2015",
                respondent = "household",
                implicates = 5)

# Removed pca for prep
data <- assemble(prep,
                 fusion.variables = c("btung", "kwh", "cooltype", "scalee", 'noheatng', "btufo", "btulp",
                                      "noacbroke","noacel","noheatel",'noheatbroke','noheatbulk'),
                 window = 2)

# Sanity check
# lapply(data, dim)
#
# # Visual check of frequencies for a harmonized variable
# round(table(data$RECS_2015$nhsldmem__np) / nrow(data[[1]]), 3)
# round(table(data$ACS_2015$nhsldmem__np) / nrow(data[[2]]), 3)

rm(prep)

#-----

# Create new custom variables

# data$RECS_2015 <- data$RECS_2015 %>%
#   mutate(
#     disconnect = scalee != "Never",
#     noheat = noheatbroke == "Yes" | noheatbulk == "Yes" |  noheatel == "Yes" | noheatng == "Yes",
#     noac = noacel == "Yes" | noacbroke == "Yes"
#   ) %>%
#   select(-all_of(c("scalee", "noacel", "noacbroke", "noheatbroke", "noheatbulk", "noheatel", "noheatng")))

#-----

# Select desired fusion variables
#fusion.vars <- c("kwh","btung","btufo","btulp","cooltype","disconnect", "noheat", "noac")
fusion.vars <- attr(data, "fusion.vars")

# Predictor variables
# This is just a fancy way to pull the predictor variables from 'data' attributes
pred.vars <- unlist(map(c("harmonized.vars", "location.vars", "spatial.vars"), ~ attr(data, .x)))

# Get fusion sequence and blocking
# Can sample 'data' if training dataset is too large/slow
fsequence <- blockchain(data = slice_sample(data$RECS_2015, n = 10e3),
                        y = fusion.vars,
                        x = pred.vars,
                        delta = 0,  # Prevent blocking
                        weight = "weight",
                        cores = 1)

#-----

# Train fusion model
file.fsn <- train(data = data$RECS_2015,
                  y = fsequence,
                  x = pred.vars,
                  file = "production/v2/RECS/2015/RECS_2015.fsn",
                  weight = "weight",
                  nfolds = 5,
                  cores = 1,
                  hyper = list(boosting = "gbdt",
                               feature_fraction = 0.8,
                               num_iterations = 9999,
                               learning_rate = 0.05)
)

#-----
# Fuse variables to ACS for multiple implicates
# Optimal settings for 'k' and 'max_dist' are unknown at moment -- using default values
sim <- fuseM(data = data$ACS_2015,
             file = file.fsn,
             k = 5,
             cores = 1,
             M = 10)  # Just try 10 implicates for now...

# Save simulation results to disk
fst::write_fst(x = sim,
               path = "production/v2/RECS/2015/RECS_2015-ACS_2015.fst",
               compress = 100)
