#!/bin/bash

outfilename=NetCDF_plan`date '+_%Y%m%d%H%M%S'`.out

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0-00:15:00 
#SBATCH --mem-per-cpu=1G

#SBATCH --output=log/${outfilename}

#SBATCH --job-name=GCM
#SBATCH --export=ALL

#SBATCH --mail-type=begin,end,fail


module load R
source activate GCMs
R -e "drake::r_make(\"src/NetCDF_plan.R\")"