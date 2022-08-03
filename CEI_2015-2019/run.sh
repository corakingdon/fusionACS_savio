#!/bin/bash

#SBATCH --job-name=cei_production
#SBATCH --account=fc_fusionacs
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --time=04:00:00 

module load r
module load r-packages

R CMD BATCH ~/repos/fusionACS_savio/CEI_2015-2019/CEI_2019_output.R /global/scratch/users/ckingdon/logs/cei_production.Rout
