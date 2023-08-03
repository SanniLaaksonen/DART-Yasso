Program CreateTest
implicit none

!real, allocatable :: state_loc(:) !Changed from integer
!character(len=10), allocatable :: state_loc(:)
real, allocatable :: state_loc(:)
real, allocatable :: state_loc_temp(:)

integer :: model_size = 12 !Edit this by hand depending on the number of sites.

real :: x_loc
integer  :: i, j, k
character(len=10) :: str

! Create storage for locations
allocate(state_loc(model_size))
allocate(state_loc_temp(model_size))

str = ''

!do i=1, model_size/6
      !do j=1,6
        !k = (i-1)*6+j
        !x_loc = real(i)/10. !divided by 10
        !state_loc(k) = x_loc
        !write(str, '(F5.1)')x_loc
        !state_loc(k) = str
      !end do
!end do

!print*, state_loc

state_loc_temp = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]
do i = 1, model_size
   state_loc(i) =  state_loc_temp(i)
end do

print*, state_loc
  
end Program CreateTest
