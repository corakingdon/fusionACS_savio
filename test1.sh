#!/bin/bash

#SBATCH --job-name=test1
#SBATCH --account=fc_fusionacs
#SBATCH --partition=savio2
#SBATCH --time=01:00:00 #one hour

Module load r

R CMD BATCH ~/repos/RECS-ACS/test1.R /global/scratch/users/ckingdon/logs/test1_log.Rout
