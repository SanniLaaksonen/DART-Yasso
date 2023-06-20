program ReadOut
  use :: netcdf
  implicit none
  
  !Define file name
  character(len=*), parameter :: file_name = 'filter_output_yasso.nc'
  character(len=*), parameter :: output_file = 'init_ensemble.dat'
  integer, parameter :: n_ens = 50
  integer, parameter :: n_state = 6
  
  !Declare variables, i as an integer
  integer :: ncid, varid, status
  integer :: i
  real, dimension(n_state, n_ens) :: Ens
  
  status = nf90_open(path = file_name, mode = nf90_nowrite, ncid = ncid)
  status = nf90_inq_varid(ncid, "state", varid)
  status = nf90_get_var(ncid, varid, Ens)
  
  open(unit = 1, file = output_file, status = 'replace')
  
  !Write Ens matrix
  do i = 1, n_ens
    write(1,*) Ens(2:6, i)
  end do
  
  close(1)
  status = nf90_close(ncid)
  
end program ReadOut
