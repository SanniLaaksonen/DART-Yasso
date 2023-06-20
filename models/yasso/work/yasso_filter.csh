#!/bin/csh
#run from the work folder
mkdir advance_model

cd advance_model #Changed from link to copy
cp ../../model/yasso .
cp ../../model/CreateInit .
cp ../../model/ReadOut .

#Copy files to the advance_model dir
cp ../../model/init_ensemble.dat .
cp ../../scripts/Simul_clim.dat .
cp ../../scripts/Simul_litter.dat .
cp ../../scripts/years.dat .
cp ../../model/ParY20.dat .
cp ../../model/ens_projection.dat .

@ ii = 1

while ($ii <= 1)

    echo "$ii" > loop.dat

    set obs_file = "../obs_seq_$ii.out"
    cp -f $obs_file ../obs_seq.out #Copy and rename for ./filter, overwrite if exists
    
    ./yasso
    ./CreateInit
    ncgen filter_input_yasso -o filter_input_yasso.nc

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
