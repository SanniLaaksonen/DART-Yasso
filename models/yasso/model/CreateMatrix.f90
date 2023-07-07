program CreateMatrix
    implicit none
    integer, parameter :: n = 2 !This is the number of observation sites, change value when needed
    integer :: state_vector_size = 6*n
    real :: a(6*50*n), b(n,50,6)
    integer :: i, j
    integer :: ensemble_size = 50
    integer :: ensemble_length
    real, allocatable, dimension(:) :: Ens_vector
    real, allocatable, dimension(:,:) :: Ens
    
    allocate(Ens(state_vector_size,ensemble_size))
    ensemble_length = ensemble_size*state_vector_size
    
    open(unit=10, file='ens_projection_sites.dat')
    read(10,*) a
    close(10)
    do i=1,n
        b(i,:,:) = transpose(reshape(a((i-1)*50*6+1:i*50*6), [6,50]))
    end do
    
    Ens = transpose(reshape(b, [50,6*n]))
    
    Ens_vector = reshape(Ens,(/ensemble_length/))
    
end program CreateMatrix