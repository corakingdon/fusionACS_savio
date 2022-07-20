#!/bin/bash

#SBATCH --job-name=recs_acs_run
#SBATCH --account=fc_fusionacs
#SBATCH --partition=savio
#SBATCH --time=01:00:00 

Module load r

R CMD BATCH ~/repos/fusionACS_savio/run.R /global/scratch/users/ckingdon/logs/run_log.Rout
