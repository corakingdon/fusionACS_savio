#!/bin/bash

#SBATCH --job-name=recs_acs_train
#SBATCH --account=fc_fusionacs
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --time=00:15:00 

module load r
module load r-packages

R CMD BATCH ~/repos/fusionACS_savio/train.R /global/scratch/users/ckingdon/logs/train_log.Rout
