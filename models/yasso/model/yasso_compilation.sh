#!/bin/csh

gfortran -I/appl/spack/v018/install-tree/gcc-11.3.0/netcdf-fortran-4.5.4-p6xyan/include -L/appl/spack/v018/install-tree/gcc-11.3.0/netcdf-fortran-4.5.4-p6xyan/lib -lnetcdff -lnetcdf -o ReadOut ReadOut.f90
