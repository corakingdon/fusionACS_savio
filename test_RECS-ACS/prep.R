# Part of the script to be run locally to prepare the data objects before
# sending to Savio

proj.dir = "C:/Users/Cora/SC2/repos/RECS-ACS/"
fusionData.dir = "C:/Users/Cora/SC2/repos/fusionData/"
setwd(fusionData.dir)
devtools::install(fusionData.dir)
library(fusionData)

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

saveRDS(data, paste0(proj.dir, "data.RDS"))


rm(prep)
