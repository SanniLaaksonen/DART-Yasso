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

@ ii = 1

while ($ii <= 4) #change the number of loops here

    echo "$ii" > loop.dat

    set obs_file = "../obs_seq_$ii.out"
    cp -f $obs_file ../obs_seq.out #Copy and rename for ./filter, overwrite if exists
    
    ./yasso
    ./CreateInit
    ncgen filter_input_yasso -o filter_input_yasso.nc
    #copy filter input
    cp filter_input_yasso.nc ../filter_input_yasso_$ii.nc

    cd ..
    cp advance_model/filter_input_yasso.nc .

    ./filter

    cd advance_model
    cp ../filter_output_yasso.nc .
    ./ReadOut
    #Save obs_seq final and filter_output_yasso.nc
    cp filter_output_yasso.nc ../filter_output_yasso_$ii.nc
    cp ../obs_seq.final ../obs_seq_$ii.final
    
    @ ii += 1 #increase loop
    
end

# rm -rf advance_model
