#!/bin/csh
#run from the work folder
mkdir advance_model

cd advance_model #Changed from link to copy
cp ../../model/yasso .
cp ../../model/CreateInit .
cp ../../model/ReadOut .

#Copy files to the advance_model dir CHECK THESE
#cp ../../model/init_ensemble.dat . #By hand
cp ../../model/init_ensemble_split_1.dat .
cp ../../model/init_ensemble_split_2.dat .
cp ../../scripts/Simul_clim.dat .
#cp ../../scripts/Simul_litter.dat . #By hand
cp ../../scripts/Simul_litter_1.dat .
cp ../../scripts/Simul_litter_2.dat .
cp ../../scripts/years.dat . #By hand
cp ../../model/ParY20.dat .
#cp ../../model/ens_projection.dat . #By hand
cp ../../model/ens_projection_sites.dat .

# rm -rf advance_model
