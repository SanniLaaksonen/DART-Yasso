program ReadOut
  use :: netcdf
  implicit none
  
  !Define file name
  character(len=*), parameter :: file_name = 'filter_output_yasso.nc'
  character(len=*), parameter :: output_file = 'init_ensemble.dat' !Original output file
  integer,parameter :: sites = 2 !Number of observation sites
  integer, parameter :: n_ens = 50
  integer, parameter :: n_state = 6*sites
  integer :: site, loop_start, loop_end
  character(len=50) :: init_file
  
  !Declare variables
  integer :: ncid, varid, status
  integer :: i, j, k
  real, dimension(n_state, n_ens) :: Ens
  integer, parameter :: n_sites = size(Ens, 2)

  real, dimension(:,:,:), allocatable :: Vectors
  allocate(Vectors(sites,6,n_sites))
  
  status = nf90_open(path = file_name, mode = nf90_nowrite, ncid = ncid)
  status = nf90_inq_varid(ncid, "state", varid)
  status = nf90_get_var(ncid, varid, Ens)
  
  
  !Define start and end for looping through Ens
  loop_start = 2
  loop_end = 6

do site = 1, sites
  
  !Create file for each site
  write (init_file, fmt='(a,i1,a)') 'init_ensemble_split_', site, '.dat'
  open(unit = 1, file = init_file, status = 'replace') !output_file

  !Write Ens matrix
  do i = 1, 50
    write(1,*) Ens(loop_start:loop_end, i)
  end do
  
  close(1)
  
  !Increase loop
  loop_start = loop_start+6
  loop_end = loop_end+6
  
 end do
 
 status = nf90_close(ncid)
  
end program ReadOut
