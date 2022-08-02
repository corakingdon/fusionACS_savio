#!/bin/bash

#SBATCH --job-name=cei_fuse
#SBATCH --account=fc_fusionacs
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --time=00:30:00 

module load r
module load r-packages

R CMD BATCH ~/repos/fusionACS_savio/CEI_2015-2019/test_fuse_script.R /global/scratch/users/ckingdon/logs/cei_fuse.Rout
