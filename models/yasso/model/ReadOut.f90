program ReadOut
  use :: netcdf
  implicit none
  
  !Define file name
  character(len=*), parameter :: file_name = 'filter_output_yasso.nc'
  character(len=*), parameter :: output_file = 'init_ensemble.dat'
  integer,parameter :: sites = 2 !Adjust this for number of sites
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
  
  !print*,Ens
  
  !Split Ens to vectors
  
  !do i = 1, n_sites
    !do j = 1, 6
      !do k = 1, sites
        !Vectors(k, j, i) = Ens((j-1)*sites+k, i)
      !end do
    !end do
  !end do
  
  !print*, Vectors
  
  loop_start = 2
  loop_end = 6

do site = 1, sites

  write (init_file, fmt='(a,i1,a)') 'init_ensemble_split_', site, '.dat'
  open(unit = 1, file = init_file, status = 'replace') !output_file

  !Write Ens matrix
  do i = 1, 50
    write(1,*) Ens(loop_start:loop_end, i) !write(1,*) Vectors(site,2:6, i) !2-6, 8-12, etc.
  end do
  
  close(1)
  
  loop_start = loop_start+6
  loop_end = loop_end+6
  
 end do
 
 status = nf90_close(ncid)
  
end program ReadOut
