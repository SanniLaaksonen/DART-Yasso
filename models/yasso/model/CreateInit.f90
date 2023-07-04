Program CreateInit
  implicit none

  integer :: ii
  integer :: ensemble_size = 50
  integer :: state_vector_size = 6
  integer :: ensemble_length
  integer :: site
  integer :: sites
  real, allocatable, dimension(:) :: loc_vector
  real, allocatable, dimension(:) :: prior_mean, prior_sd
  real, allocatable, dimension(:) :: post_mean, post_sd
  real, allocatable, dimension(:,:) :: Ens
  real, allocatable, dimension(:) :: Ens_vector
  character(len=32) :: loc_fmt, ens_fmt, post_fmt
  character(len=50) :: ens_file
  character(len=50) :: yasso_file
  
  allocate(loc_vector(state_vector_size))
  allocate(prior_mean(state_vector_size))
  allocate(prior_sd(state_vector_size))
  allocate(post_mean(state_vector_size))
  allocate(post_sd(state_vector_size))
  allocate(Ens(state_vector_size,ensemble_size))

  prior_mean = 1.
  prior_sd = 0.6
  post_mean = 1.
  post_sd = 0.6
  
  ensemble_length = ensemble_size*state_vector_size

  write(loc_fmt, '(a,i0,a)') '(A12,', state_vector_size-1, '(F3.1:", "),F3.1,A)'
  write(ens_fmt, '(a,i0,a)') '(A3,', ensemble_length-1, '(F7.4:", "),F7.4,A)'
  write(post_fmt, '(a,i0,a)') '(A2,', state_vector_size-1, '(F3.1:", "),F3.1,A)'
  
  sites = 2 !number of sites

  do site = 1, sites
     loc_vector = site !lokaatiovektori
     
     !open(20, file='ens_projection.dat')
     write (ens_file, fmt='(a,i1,a)') 'ens_projection_split_', site, '.dat'
     open(20, file=ens_file)
     read(20,*) Ens
     close(20)

     Ens_vector = reshape(Ens,(/ensemble_length/))
  
     !open(10, file='filter_input_yasso')
     write (yasso_file, fmt='(a,i1)') 'filter_input_yasso_', site
     open(10, file=yasso_file)

     write(10,'(a)') 'netcdf filter_input {'
     write(10,'(a)') 'dimensions:'
     write(10,*)     ' member =', ensemble_size, ';'
     write(10,'(a)') '  metadatalength = 32 ;'
     write(10,*)     ' location = ', state_vector_size, ';'
     write(10,'(a)') ' time = UNLIMITED ; // (1 currently)'
     write(10,'(a)') 'variables:'
     write(10,'(a)')
     write(10,'(a)') ' char MemberMetadata(member, metadatalength) ;'
     write(10,'(a)') '  MemberMetadata:long_name = "description of each member" ;'
     write(10,'(a)')
     write(10,'(a)') ' double location(location) ;'
     write(10,'(a)') '  location:short_name = "loc1d" ;'
     write(10,'(a)') '  location:long_name = "Field number" ;'
     write(10,'(a)') '  location:dimension = 1 ;'
     write(10,'(a)') '  location:valid_range = 1., 10. ;'
     write(10,'(a)') 
     write(10,'(a)') ' double state(time, member, location) ;'
     write(10,'(a)') '  state:long_name = "the ensemble of model states" ;'
     write(10,'(a)') 
     write(10,'(a)') ' double state_priorinf_mean(time, location) ;'
     write(10,'(a)') '  state_priorinf_mean:long_name = "prior inflation value" ;'
     write(10,'(a)')
     write(10,'(a)') ' double state_priorinf_sd(time, location) ;'
     write(10,'(a)') '  state_priorinf_sd:long_name = "prior inflation standard deviation" ;'
     write(10,'(a)')
     write(10,'(a)') ' double state_postinf_mean(time, location) ;'
     write(10,'(a)') '  state_postinf_mean:long_name = "posterior inflation value" ;'
     write(10,'(a)') 
     write(10,'(a)') ' double state_postinf_sd(time, location) ;'
     write(10,'(a)') '  state_postinf_sd:long_name = "posterior inflation standard deviation" ;'
     write(10,'(a)')
     write(10,'(a)') ' double time(time) ;'
     write(10,'(a)') '  time:long_name = "valid time of the model state" ;'
     write(10,'(a)') '  time:axis = "T" ;'
     write(10,'(a)') '  time:cartesian_axis = "T" ;'
     write(10,'(a)') '  time:calendar = "none" ;'
     write(10,'(a)') '  time:units = "years" ;'
     write(10,'(a)') 
     write(10,'(a)') ' double advance_to_time ;'
     write(10,'(a)') '  advance_to_time:long_name = "desired time at end of the next model advance" ;'
     write(10,'(a)') '  advance_to_time:axis = "T" ;'
     write(10,'(a)') '  advance_to_time:cartesian_axis = "T" ;'
     write(10,'(a)') '  advance_to_time:calendar = "none" ;'
     write(10,'(a)') '  advance_to_time:units = "years" ;'
     write(10,'(a)') 
     write(10,'(a)') '// global attributes:'
     write(10,'(a)') '  :title = "an ensemble of spun-up model states" ;'
     write(10,'(a)') '  :version = "$Id: $" ;'
     write(10,'(a)') '  :model = "Yasso" ;'
     write(10,'(a)') '  :model_forcing = 8. ;'
     write(10,'(a)') '  :model_deltat = 0.05 ;'
     write(10,'(a)') '  :history = "Varied initial states based on prior drivers" ;'
     write(10,'(a)') 'data:'
     write(10,'(a)')
     write(10,'(a)') ' MemberMetadata ='

     do ii = 1, ensemble_size-1
        write(10,'(A21,I3,A2)') '  "ensemble member   ',ii,'",'
     end do
     write(10,'(A21,I3,A3)') '  "ensemble member   ',ensemble_size,'" ;'

     write(10,'(a)')
     write(10,loc_fmt) ' location = ', loc_vector(1:state_vector_size-1), loc_vector(state_vector_size), ' ;'
     write(10,'(a)')
     write(10,'(a)') 'state ='
     write(10,ens_fmt) '   ', Ens_vector(1:ensemble_length-1), ens_vector(ensemble_length), ' ;'
     write(10,'(a)')
     write(10,'(a)') ' state_priorinf_mean='
     write(10,post_fmt) '  ', prior_mean(1:state_vector_size-1), prior_mean(state_vector_size), ' ;'
     write(10,'(a)')
     write(10,'(a)') ' state_priorinf_sd ='
     write(10,post_fmt) '  ', prior_sd(1:state_vector_size-1), prior_sd(state_vector_size), ' ;'
     write(10,'(a)')
     write(10,'(a)') ' state_postinf_mean ='
     write(10,post_fmt) '  ', post_mean(1:state_vector_size-1), post_mean(state_vector_size), ' ;'
     write(10,'(a)')
     write(10,'(a)') ' state_postinf_sd ='
     write(10,post_fmt) '  ', post_sd(1:state_vector_size-1), post_sd(state_vector_size), ' ;'
     write(10,'(a)')
     write(10,'(a)') ' time = 0. ;'
     write(10,'(a)')
     write(10,'(a)') ' advance_to_time = 0. ;'
     write(10,'(a)') '}'
  
     close(10)
  end do

  
end Program CreateInit
