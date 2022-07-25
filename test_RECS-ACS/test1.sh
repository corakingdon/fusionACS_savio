#!/bin/bash

#SBATCH --job-name=test1
#SBATCH --account=fc_fusionacs
#SBATCH --partition=savio2
#SBATCH --time=00:04:00 

Module load r

R CMD BATCH ~/repos/fusionACS_savio/test1.R /global/scratch/users/ckingdon/logs/test1_log.Rout
