! DART software - Copyright UCAR. This open source software is provided
! by UCAR, "as is", without charge, subject to all terms of use at
! http://www.image.ucar.edu/DAReS/DART/DART_download

! ! in this section, define the quantities of interest. the name must
! ! start with QTY_xxx and be less than 32 characters total.
! ! if there are units, min/max values, pdf, etc you can add one or
! ! more name=value pairs.  at this point there *cannot* be spaces
! ! around the equals sign.  the value can have spaces if it is
! ! surrounded by double quotes.  e.g. desc="assumes dry air density"
! !
! ! comment lines (like these) can be added if they start with a second !
 
! BEGIN DART PREPROCESS QUANTITY DEFINITIONS
!
! ! QTY_STATE_VARIABLE is a generic quantity which is predefined
! ! by the system and available for code to use without needing
! ! a separate definition here. It is frequently used in models
! ! where the items in the state vector do not directly represent
! ! a physical quantity in the model.
! !
! ! These additional QTYs are available for more specialized cases.
! !
!
!   QTY_CARBON_SUM                  
!   QTY_ACID_SOLUBLE              
!   QTY_WATER_SOLUBLE            
!   QTY_ALCOHOL_SOLUBLE            
!   QTY_NON_SOLUBLE
!   QTY_HUMUS
! 
! END DART PREPROCESS QUANTITY DEFINITIONS
