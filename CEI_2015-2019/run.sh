#!/bin/bash

#SBATCH --job-name=cei_train
#SBATCH --account=fc_fusionacs
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --time=00:10:00 

module load r
module load r-packages

R CMD BATCH ~/repos/fusionACS_savio/CEI_2015-2019/train.R /global/scratch/users/ckingdon/logs/cei_train_log.Rout
