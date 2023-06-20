#!/bin/bash -l
#SBATCH --job-name=r_netcdf
#SBATCH --account=project_2002163
#SBATCH --output=output.txt
#SBATCH --error=errors.txt
#SBATCH --partition=fmi
#SBATCH --time=00:05:00
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=1000

module load r-env

if test -f ~/.Renviron; then
    sed -i '/TMPDIR/d' ~/.Renviron
fi

echo "TMPDIR=/scratch/2002163" >> ~/.Renviron

srun apptainer_wrapper exec Rscript --no-save CreateInit.R
