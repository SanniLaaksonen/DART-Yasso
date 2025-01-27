! Yasso model for DART

Program Yasso
use yasso_core20

implicit none

integer :: ii, jj, length, alku, loppu
integer :: loop, fyear, lyear
integer :: EnsSize = 50
integer :: lSimul = 77, lAskov = 32, lGrig = 50, lKursk = 39, lRoth = 50, lUltuna = 52, lVers = 80 !81 old size for vers
integer, allocatable, dimension(:) :: years
real :: DN = 0., leac = 0.
real :: TA, CP, s1, s2
real, dimension(5) :: init, NCP
real, allocatable, dimension(:) :: prec
real, allocatable, dimension(:,:) :: nli
real, allocatable, dimension(:,:) :: temp
real, dimension(35) :: YaPa
character(len=50) :: data_line = '(F12.3,5F12.7)'

length = lSimul !Size of weather conditions files

allocate(prec(length))
allocate(temp(length,12))
allocate(years(length))
allocate(nli(length,5))

! Read in the site specific climate file
open(18, file='Simul_clim.dat')
do ii = 1, length
   read(18,*) years(ii), temp(ii,:), prec(ii)
end do
close(18)

! Read in the site specific litter file
open(19, file='Simul_litter.dat')
do ii = 1, length
   read(19,*) years(ii), nli(ii,:)
end do
close(19)

! Yasso parameters
open(14, file = 'ParY20.dat')
read(14,*) YaPa
close(14)

! Check which loop member the model is run on

open(16, file= 'loop.dat')
read(16, *) loop
close(16)

! Read the years the model is run for

open(17, file= 'years.dat')

do ii = 1, loop
   read(17,*) fyear, lyear
end do
close(17)

do ii = 1, length
   if(years(ii) .eq. fyear) then
      alku = ii
   end if

   if(years(ii) .eq. lyear) then
      loppu = ii
   end if
end do

open(11, file='init_ensemble_split_1.dat')

open(21, file='ens_projection.dat')

do jj = 1, EnsSize

   read(11,*) init

   ! Run Yasso if the start time isn't 0. (The initial ensemble starts at the first observation so we don't want to move it forward, but compare the observation to it directly)
   if (alku .GT. 0) then
      ! alku is the time of the previous observation, 0 at the beginning, and we have already done that so start from the next year
      do ii = alku, loppu
         NCP = -999.
         call mod5c(YaPa,1.,temp(ii,:),prec(ii),init,nli(ii,:),DN,leac,NCP,.FALSE.)
         init = NCP
         s1 = sum(NCP)    
      end do

      write(21,*) sum(NCP), NCP

   end if

end do

close(11)
close(21)

End Program Yasso
