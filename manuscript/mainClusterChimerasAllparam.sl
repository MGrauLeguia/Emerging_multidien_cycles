#!/bin/bash 

 
#SBATCH -J ChimeraMultidien    # Job Name 
#SBATCH --time=200:15:00
#SBATCH -C intel # Architecture

#SBATCH -o /YOURPATH/errors/%x-%j.out # File to which STDOUT will be written
#SBATCH -e /YOURPATH//errors/%x-%j.err # File to which STDERR will be written

#SBATCH --array=1-66    # Array definition
#SBATCH --mem 16000

sleep $SLURM_ARRAY_TASK_ID

module load MATLAB/2021a

matlab -nodesktop -nosplash -r  "mainClusterChimerasAllparam(${SLURM_ARRAY_TASK_ID})"
