! COPYRIGHT (c) 2000 Council for the Central Laboratory
!               of the Research Councils
! Original date 13 September 1999
! 01/11/00  Entries in IW initialized to zero in MA57O/OD to avoid copy
!           of unassigned variables by MA57E/ED.
!           AINPUT and IINPUT reset in call to MA57E/ED.
!           sinfo%more initialized to 0.
!           MA27 changed to MA57 in allocation error return.
!           calls to MC41 changed to MC71 calls.
! 19/12/01  Optional parameter added to enquire routine to return perturbation
!           factors%pivoting added to hold pivoting option
!           la increased when Schnabel-Eskow option invoked
!           sinfo%more removed.
! 10/05/02  factors of data type ma57_factors made intent(in) in solves
! 24/5/04 Statment functions in MA57U/UD replaced by in-line code.

! 12th July 2004 Version 1.0.0. Version numbering added.
! 20/07/04  Several changes incorporated for HSL 2004 code.
!           Removed unused INT,ABS from MA57U/UD
!           INFO(32), INFO(33), and INFO(34) added
!           INFO(32): number of zeros in the triangle of the factors
!           INFO(33): number of zeros in the rectangle of the factors
!           INFO(34): number of zero columns in rectangle of the factors
!           Static pivoting available (controlled by CNTL(4))

! 31st July 2004 Version 2.0.0 established at HSL 2004 release.
! 1 Nov 2004 Version 2.0.1. Defaults changed, since they are taken from MA57.
! 7 March 2005 Version 3.0.0.  Mostly a large set of changes inherited from
!           the MA57 (F77) code.  See the header for MA57A/AD for details
!           of these.  Changes within the F90 code include: change of
!           default for CONTROL%ORDERING, introduction of new component
!           AINFO%ORDERING, correction of error in deallocate statement
!           in solve1 and solve2, and changes to diagnostic output format.
! 14 June 2005  Version 3.1.0. The space needed for ma57bd now recomputed in
!           the factorize entry so that the user can change the value of
!           control%pivoting and control%scaling between calls to analyse
!           and factorize.  cond2, berr, berr2, error added to sinfo to
!           return condition number for category 2 equations, backward
!           error, and forward error for category 2 equations as in
!           Arioli, Demmel, and Duff (1989).
!           control%convergence added so that cntl(3) can be set for
!           ma57dd call.
!           Small change to write statement for failure in finalize.
! 28 February 2006. Version 3.2.0. To avoid memory leaks, ma57_initialize and
!        ma57_finalize leave pointer component null instead having zero size.
! 4 December 2006. Version 4.0.0. Pointer arrays replaced by allocatables.
! 20 September 2007.  Version 4.1.0. Code tidied to interface with
!           Version 3.2.0 of MA57 .. an added control parameter
!           rank_deficient allows the option of dropping blocks of
!           small entries during the factorization.
! 1 April 2010.  Version 4.2.0.
!           Component ainfo%ordering added and assigned return value of
!           info(36) from MA57AD to indicate ordering actually used.
!           The message in the error return from MA57_FACTORIZE
!           corrected to show return is from FACTORIZE rather than
!           ANALYSE.
!           The components of info parameters are given default values.
! 6 Aug 2010.  Version 4.2.1
!           Fix spec sheet to read "HSL_ZD11" rather than "ZD11"

module hsl_ma57_double
   use hsl_zd11_double
   implicit none
   integer, parameter, private :: wp = kind(0.0d0)

   type ma57_factors
     private
      integer, allocatable :: keep(:)
      integer, allocatable :: iw(:)
      real(wp), allocatable :: val(:)
      integer :: n        ! Matrix order
      integer :: nrltot   ! Size for val without compression
      integer :: nirtot   ! Size for iw without compression
      integer :: nrlnec   ! Size for val with compression
      integer :: nirnec   ! Size for iw with compression
      integer :: pivoting ! Set to pivoting option used in factorize
      integer :: scaling  ! Set to scaling option used in factorize
      integer :: static   ! Set to indicate if static pivots chosen
   end type ma57_factors

   type ma57_control
      real(wp) :: multiplier ! Factor by which arrays sizes are to be
                        ! increased if they are too small
      real(wp) :: reduce ! if previously allocated internal workspace arrays
                        !  are greater than reduce times the currently
                        !  required sizes, they are reset to current requirments
      real(wp) :: u     ! Pivot threshold
      real(wp) :: static_tolerance ! used for setting static pivot level
      real(wp) :: static_level ! used for switch to static
      real(wp) :: tolerance ! anything less than this is considered zero
      real(wp) :: convergence ! used to monitor convergence in iterative
                              ! refinement
      integer :: lp     ! Unit for error messages
      integer :: wp     ! Unit for warning messages
      integer :: mp     ! Unit for monitor output
      integer :: sp     ! Unit for statistical output
      integer :: ldiag  ! Controls level of diagnostic output
      integer :: nemin  ! Minimum number of eliminations in a step
      integer :: factorblocking ! Level 3 blocking in factorize
      integer :: solveblocking ! Level 2 and 3 blocking in solve
      integer :: la     ! Initial size for real array for the factors.
                        ! If less than nrlnec, default size used.
      integer :: liw    ! Initial size for integer array for the factors.
                        ! If less than nirnec, default size used.
      integer :: maxla  ! Max. size for real array for the factors.
      integer :: maxliw ! Max. size for integer array for the factors.
      integer :: pivoting  ! Controls pivoting:
                 !  1  Numerical pivoting will be performed.
                 !  2  No pivoting will be performed and an error exit will
                 !     occur immediately a pivot sign change is detected.
                 !  3  No pivoting will be performed and an error exit will
                 !     occur if a zero pivot is detected.
                 !  4  No pivoting is performed but pivots are changed to
                 !     all be positive.
      integer :: thresh ! Controls threshold for detecting full rows in analyse
                 !     Registered as percentage of N
                 ! 100 Only fully dense rows detected (default)
      integer :: ordering  ! Controls ordering:
                 !  Note that this is overridden by using optional parameter
                 !  perm in analyse call with equivalent action to 1.
                 !  0  AMD using MC47
                 !  1  User defined
                 !  2  AMD using MC50
                 !  3  Min deg as in MA57
                 !  4  Metis_nodend ordering
                 ! >4  Presently equivalent to 0 but may chnage
      integer :: scaling  ! Controls scaling:
                 !  0  No scaling
                 ! >0  Scaling using MC64 but may change for > 1
      integer :: rank_deficient  ! Controls handling rank deficiency:
                 !  0  No control
                 ! >0  Small entries removed during factorization

   end type ma57_control

   type ma57_ainfo
      real(wp) :: opsa = -1.0_wp  ! Anticipated # operations in assembly
      real(wp) :: opse = -1.0_wp  ! Anticipated # operations in elimination
      integer :: flag = 0     ! Flags success or failure case
      integer :: more = 0     ! More information on failure
      integer :: nsteps = -1  ! Number of elimination steps
      integer :: nrltot = -1  ! Size for a without compression
      integer :: nirtot = -1  ! Size for iw without compression
      integer :: nrlnec = -1  ! Size for a with compression
      integer :: nirnec = -1  ! Size for iw with compression
      integer :: nrladu = -1  ! Number of reals to hold factors
      integer :: niradu = -1  ! Number of integers to hold factors
      integer :: ncmpa = -1   ! Number of compresses
      integer :: ordering = -1! Indicates the ordering actually used
      integer :: oor = 0      ! Number of indices out-of-range
      integer :: dup = 0      ! Number of duplicates
      integer :: maxfrt = -1  ! Forecast maximum front size
      integer :: stat = 0     ! STAT value after allocate failure
   end type ma57_ainfo

   type ma57_finfo
      real(wp) :: opsa = -1.0_wp  ! Number of operations in assembly
      real(wp) :: opse = -1.0_wp  ! Number of operations in elimination
      real(wp) :: opsb = -1.0_wp  ! Additional number of operations for BLAS
      real(wp) :: maxchange = -1.0_wp 
                  ! Largest pivot modification when pivoting=4
      real(wp) :: smin = -1.0_wp  ! Minimum scaling factor
      real(wp) :: smax = -1.0_wp  ! Maximum scaling factor
      integer :: flag = 0     ! Flags success or failure case
      integer :: more = 0     ! More information on failure
      integer :: maxfrt = -1  ! Largest front size
      integer :: nebdu = -1   ! Number of entries in factors
      integer :: nrlbdu = -1  ! Number of reals that hold factors
      integer :: nirbdu = -1  ! Number of integers that hold factors
      integer :: nrltot = -1  ! Size for a without compression
      integer :: nirtot = -1  ! Size for iw without compression
      integer :: nrlnec = -1  ! Size for a with compression
      integer :: nirnec = -1  ! Size for iw with compression
      integer :: ncmpbr = -1  ! Number of compresses of real data
      integer :: ncmpbi = -1  ! Number of compresses of integer data
      integer :: ntwo = -1    ! Number of 2x2 pivots
      integer :: neig = -1    ! Number of negative eigenvalues
      integer :: delay = -1   ! Number of delayed pivots (total)
      integer :: signc = -1   ! Number of pivot sign changes (pivoting=3)
      integer :: static = -1  ! Number of static pivots chosen
      integer :: modstep = -1 ! First pivot modification when pivoting=4
      integer :: rank = -1    ! Rank of original factorization
      integer :: stat = 0     ! STAT value after allocate failure
   end type ma57_finfo

   type ma57_sinfo
      real(wp) :: cond = -1.0_wp   
          ! Condition number of matrix (category 1 equations)
      real(wp) :: cond2 = -1.0_wp  
          ! Condition number of matrix (category 2 equations)
      real(wp) :: berr = -1.0_wp   
          ! Condition number of matrix (category 1 equations)
      real(wp) :: berr2 = -1.0_wp  
          ! Condition number of matrix (category 2 equations)
      real(wp) :: error = -1.0_wp  
          ! Estimate of forward error using above data
      integer :: flag = 0    ! Flags success or failure case
      integer :: stat = 0    ! STAT value after allocate failure
   end type ma57_sinfo
   interface ma57_solve
! ma57_solve1 for 1 rhs  and ma57_solve2 for more than 1.
      module procedure ma57_solve1,ma57_solve2
   end interface

   interface ma57_part_solve
! ma57_part_solve1 for 1 rhs  and ma57_part_solve2 for more than 1.
      module procedure ma57_part_solve1,ma57_part_solve2
   end interface

contains

   subroutine ma57_initialize(factors,control)
      type(ma57_factors), intent(out), optional :: factors
      type(ma57_control), intent(out), optional :: control
      integer icntl(20),stat
      real(wp) cntl(5)
      if (present(factors)) then
        factors%n = 0
        deallocate(factors%keep,factors%val,factors%iw,stat=stat)
      end if
      if (present(control)) then
          call ma57id(cntl,icntl)
          control%u = cntl(1)
          control%tolerance = cntl(2)
          control%convergence = cntl(3)
          control%static_tolerance = cntl(4)
          control%static_level = cntl(5)
          control%lp = icntl(1)
          control%wp = icntl(2)
          control%mp = icntl(3)
          control%sp = icntl(4)
          control%ldiag = icntl(5)
          control%pivoting = icntl(7)
          control%ordering = icntl(6)
          control%scaling = icntl(15)
          control%factorblocking = icntl(11)
          control%nemin = icntl(12)
          control%solveblocking = icntl(13)
          control%thresh = icntl(14)
          control%rank_deficient = icntl(16)
          control%la = 0
          control%liw = 0
          control%maxla = huge(0)
          control%maxliw = huge(0)
          control%multiplier = 2.0
          control%reduce     = 2.0
      end if
    end subroutine ma57_initialize

   subroutine ma57_analyse(matrix,factors,control,ainfo,perm)
      type(zd11_type), intent(in) :: matrix
      type(ma57_factors), intent(inout) :: factors
      type(ma57_control), intent(in) :: control
      type(ma57_ainfo), intent(out) :: ainfo
      integer, intent(in), optional :: perm(matrix%n) ! Pivotal sequence

      integer, allocatable :: iw1(:)
      integer :: lkeep,n,ne,stat,icntl(20),info(40),rspace
      real(wp) rinfo(20)

      icntl(1) = control%lp
      icntl(2) = control%wp
      icntl(3) = control%mp
      icntl(4) = control%sp
      icntl(5) = control%ldiag
      icntl(6) = control%ordering
      icntl(12)  = control%nemin
      icntl(14) = control%thresh
! The next two are necessary so that the correct storage can be allocated
! No longer needed for internal purposes but icntl(7) is also used by
!     analyse to determine ordering if system is deemed positive definite
      icntl(7)  = control%pivoting
      icntl(15) = control%scaling
      n = matrix%n
      ne = matrix%ne
      stat = 0
      lkeep = 5*n+ne+max(n,ne)+42

      if(allocated(factors%keep)) then
         if(size(factors%keep)/=lkeep) then
            deallocate(factors%keep,stat=stat)
            if (stat/=0) go to 100
            allocate(factors%keep(lkeep),stat=stat)
            if (stat/=0) go to 100
         end if
      else
         allocate(factors%keep(lkeep),stat=stat)
         if (stat/=0) go to 100
      end if

! Override value of icntl(6) if perm present
      if (present(perm)) then
         factors%keep(1:n) = perm(1:n)
         icntl(6)=1
      end if

      allocate (iw1(5*n),stat=stat)
      if (stat/=0) go to 100

      call ma57ad(n,ne,matrix%row,matrix%col, &
               lkeep,factors%keep,iw1,icntl,info,rinfo)

! Adjust so that we don't allocate too much space in factorize
      rspace = 0
      if (control%pivoting == 4) rspace = rspace + n + 5
      if (control%scaling == 1)  rspace = rspace + n
      factors%n = n
      factors%nrltot = info(9)  - rspace
      factors%nirtot = info(10)
      factors%nrlnec = info(11) - rspace
      factors%nirnec = info(12)

      ainfo%opsa   = rinfo(1)
      ainfo%opse   = rinfo(2)
      ainfo%flag   = info(1)
      if (info(1) == -18) ainfo%flag   = -10
      ainfo%more   = info(2)
      ainfo%oor    = info(3)
      ainfo%dup    = info(4)
      ainfo%nrladu = info(5)
      ainfo%niradu = info(6)
      ainfo%maxfrt = info(7)
      ainfo%nsteps  = info(8)
      ainfo%nrltot = info(9)
      ainfo%nirtot = info(10)
      ainfo%nrlnec = info(11)
      ainfo%nirnec = info(12)
      ainfo%ncmpa  = info(13)
      ainfo%ordering = info(36)

      deallocate (iw1, stat=stat)
      if (stat/=0) go to 100
      return

  100 if (control%ldiag>0 .and. control%lp>0 ) &
          write (control%lp,'(/a/a,i5)') &
         'Error return from MA57_ANALYSE: flag = -3', &
         'Allocate or deallocate failed with STAT=',stat
       ainfo%flag = -3
       ainfo%stat = stat

   end subroutine ma57_analyse

   subroutine ma57_factorize(matrix,factors,control,finfo)
      type(zd11_type), intent(in) :: matrix
      type(ma57_factors), intent(inout) :: factors
      type(ma57_control), intent(in) :: control
      type(ma57_finfo), intent(out) :: finfo

      integer :: la,liw,lkeep,oldla,oldliw
      integer stat  ! stat value in allocate statements

      integer icntl(20),info(40),n,exla,expne
      real(wp) cntl(5),rinfo(20)

      integer, allocatable :: iwork(:)
      real(wp), allocatable :: temp(:)
      integer, allocatable :: itemp(:)

      n = matrix%n
      lkeep = 5*n+matrix%ne+max(n,matrix%ne)+42
      allocate (iwork(n),stat=stat)
      if (stat/=0) go to 100

      if(factors%n/=matrix%n) then
         if (control%ldiag>0 .and. control%lp>0 ) &
         write (control%lp,'(/a/a,i12,a,i12)') &
         'Error return from MA57_FACTORIZE: flag = -1', &
         'MATRIX%N has the value', &
         matrix%n,' instead of',factors%n
       finfo%flag = -1
       finfo%more = factors%n
       return
      end if

      cntl(1) = control%u
      cntl(2) = control%tolerance
      cntl(4) = control%static_tolerance
      cntl(5) =  control%static_level
      icntl(1) = control%lp
      icntl(2) = control%wp
      icntl(3) = control%mp
      icntl(4) = control%sp
      icntl(5) = control%ldiag
      icntl(7) = control%pivoting
      factors%pivoting = control%pivoting
      factors%scaling = control%scaling
      icntl(8) = 1
      icntl(11) = control%factorblocking
      icntl(12) = control%nemin
      icntl(15) = control%scaling
      icntl(16) =  control%rank_deficient
      stat = 0

      expne = factors%keep(matrix%n+2)

      la = control%la
      if(la<factors%nrlnec)then
         la = 0
         if(allocated(factors%val))la = size(factors%val)
         if(la>control%reduce*factors%nrltot) la = factors%nrltot
         if(la<factors%nrlnec) la = factors%nrltot
      end if

! Needed because explicitly removed from factors%nrlnec and factors%nrltot
         exla = 0
         if(control%pivoting == 4) exla =  factors%n + 5
         if(control%scaling == 1)  exla =  exla + factors%n
! Space for biga is already in la but not in exla
         la = max(la+exla,exla+expne+2)
         if(control%scaling == 1) la = max(la,exla+3*expne+3*factors%n+1)

      if(allocated(factors%val))then
         if(la/=size(factors%val))then
            deallocate(factors%val,stat=stat)
            if (stat/=0) go to 100
            allocate(factors%val(la),stat=stat)
            if (stat/=0) go to 100
         end if
      else
         allocate(factors%val(la),stat=stat)
         if (stat/=0) go to 100
      end if

      liw = control%liw
      if(liw<factors%nirnec)then
         liw = 0
         if(allocated(factors%iw))liw = size(factors%iw)
         if(liw>control%reduce*factors%nirnec) liw = factors%nirtot
         if(liw<factors%nirnec) liw = factors%nirtot
      end if

      if(control%scaling == 1) liw = max(liw,3*expne+5*factors%n+1)

      if(allocated(factors%iw))then
         if(liw/=size(factors%iw))then
            deallocate(factors%iw,stat=stat)
            if (stat/=0) go to 100
            allocate(factors%iw(liw),stat=stat)
            if (stat/=0) go to 100
         end if
      else
         allocate(factors%iw(liw),stat=stat)
         if (stat/=0) go to 100
      end if

      do
         call ma57bd(matrix%n,matrix%ne,matrix%val,factors%val, &
                  la,factors%iw,liw,lkeep,factors%keep,iwork,icntl,cntl, &
                  info,rinfo)
         finfo%flag = info(1)

         if (info(1)==11) then
            oldliw = liw
            liw = control%multiplier*liw
            if (liw>control%maxliw) then
               if (control%ldiag>0 .and. control%lp>0 ) &
                 write (control%lp,'(/a/a,i10)') &
                 'Error return from MA57_FACTORIZE: iflag = -8 ', &
                 'Main integer array needs to be bigger than', control%maxliw
               finfo%flag = -8
               return
            end if

! Expand integer space
            allocate (itemp(oldliw),stat=stat)
            if (stat/=0) go to 100
            itemp(1:oldliw) = factors%iw(1:oldliw)
            deallocate (factors%iw,stat=stat)
            if (stat/=0) go to 100
            allocate (factors%iw(liw),stat=stat)
            if (stat/=0) go to 100
            call ma57ed &
                  (matrix%n,1,factors%keep,factors%val,la,factors%val,la, &
                   itemp,oldliw,factors%iw,liw,info)
            deallocate (itemp,stat=stat)
            if (stat/=0) go to 100

         else if (info(1)==10) then
            oldla = la
            la = control%multiplier*la
            if (la>control%maxla) then
               if (control%ldiag>0 .and. control%lp>0 ) &
                 write (control%lp,'(/a/a,i10)') &
                 'Error return from MA57_FACTORIZE: flag = -7 ', &
                 'Main real array needs to be bigger than', control%maxla
               finfo%flag = -7
               return
            end if

! Expand real space
            allocate (temp(oldla),stat=stat)
            if (stat/=0) go to 100
            temp(1:oldla) = factors%val(1:oldla)
            deallocate (factors%val,stat=stat)
            if (stat/=0) go to 100
            allocate (factors%val(la),stat=stat)
            if (stat/=0) go to 100
            call ma57ed &
                 (matrix%n,0,factors%keep,temp,oldla,factors%val,la, &
                 factors%iw,liw,factors%iw,liw,info)
            deallocate (temp,stat=stat)
            if (stat/=0) go to 100

         else
            exit

         end if

      end do

      deallocate (iwork,stat=stat)
      if (stat/=0) go to 100


      finfo%more = info(2)
      if (info(1)>=0) then
        finfo%nebdu  = info(14)
        finfo%nrlbdu = info(15)
        finfo%nirbdu = info(16)
        finfo%nrlnec = info(17)
        finfo%nirnec = info(18)
        finfo%nrltot = info(19)
        finfo%nirtot = info(20)
        finfo%maxfrt = info(21)
        finfo%ntwo   = info(22)
        finfo%delay  = info(23)
        finfo%neig   = info(24)
        finfo%rank   = info(25)
        finfo%signc  = info(26)
        finfo%static = info(35)
        factors%static = 0
        if (finfo%static > 0) factors%static = 1
        finfo%modstep= info(27)
        finfo%ncmpbr = info(28)
        finfo%ncmpbi = info(29)
        finfo%opsa   = rinfo(3)
        finfo%opse   = rinfo(4)
        finfo%opsb   = rinfo(5)
        finfo%smin   = rinfo(16)
        finfo%smax   = rinfo(17)
        if (finfo%modstep > 0) finfo%maxchange = rinfo(14)
      end if

      return

  100 if (control%ldiag>0 .and. control%lp>0 ) &
         write (control%lp,'(/a/a,i5)') &
         'Error return from MA57_FACTORIZE: flag = -3', &
         'Allocate or deallocate failed with STAT=',stat
       finfo%flag = -3
       finfo%stat = stat

   end subroutine ma57_factorize

   subroutine ma57_solve2(matrix,factors,x,control,sinfo,rhs,iter,cond)
! Solve subroutine for multiple right-hand sides
      type(zd11_type), intent(in) :: matrix
      type(ma57_factors), intent(in) :: factors
      real(wp), intent(inout) :: x(:,:)
      type(ma57_control), intent(in) :: control
      type(ma57_sinfo), intent(out) :: sinfo
      real(wp), optional, intent(in) :: rhs(:,:)
      integer, optional, intent(in) :: iter
      integer, optional, intent(in) :: cond
      integer icntl(20),info(40),job,stat
      real(wp) cntl(5),rinfo(20),zero
      integer i,lw,n,nrhs

      integer, allocatable :: iwork(:)
      real(wp), allocatable :: work(:),resid(:),start(:,:)

      parameter (zero=0.0d0)
      n = matrix%n

      nrhs = size(x,2)

      stat = 0
      sinfo%flag = 0

! If rhs is present, then ma57dd will be called
! If iter is also present, then ADD algorithm is used
! If cond is also present, then condition number and error estimated

! lw is length of array work
      lw = n*nrhs
      if (present(rhs))  lw = n
      if (present(iter)) lw = 3*n
      if (factors%static == 1) lw = 3*n
      if (present(cond)) lw = 4*n

      allocate (iwork(n),work(lw),resid(n),stat=stat)
      if (stat/=0) go to 100

      if (factors%static == 1 .and. .not. present(rhs)) &
          allocate(start(n,nrhs),stat=stat)
      if (stat/=0) go to 100

      icntl(1) = control%lp
      icntl(2) = control%wp
      icntl(3) = control%mp
      icntl(4) = control%sp
      icntl(5) = control%ldiag
      icntl(13) = control%solveblocking
      icntl(15) = control%scaling

      cntl(3) = control%convergence

      if (present(iter)) then
! If iter is present, then rhs must be also, and user must set x.
        icntl(9)=100
        icntl(10)=0
        if (present(cond)) icntl(10)=1
        job = 2
        do i = 1,nrhs
        call ma57dd(job,matrix%n,matrix%ne,matrix%val,matrix%row,matrix%col, &
          factors%val,size(factors%val),factors%iw, &
          size(factors%iw),rhs(:,i), &
          x(:,i),resid,work,iwork,icntl,cntl,info,rinfo)
        enddo
        if (present(cond)) then
          sinfo%cond  = rinfo(11)
          sinfo%cond2 = rinfo(12)
          sinfo%berr  = rinfo(6)
          sinfo%berr2 = rinfo(7)
          sinfo%error = rinfo(13)
        endif
      else
        if(present(rhs)) then
          icntl(9) = 1
          icntl(10) = 0
          job = 2
          do i = 1,nrhs
          call ma57dd(job,matrix%n,matrix%ne,matrix%val,matrix%row, &
            matrix%col,factors%val,size(factors%val),factors%iw, &
            size(factors%iw),rhs(:,i), &
            x(:,i),resid,work,iwork,icntl,cntl,info,rinfo)
          enddo
        else
          if (factors%static == 1) then
            icntl(9) = 1
            icntl(10) = 0
            job = 2
            start = zero
            do i = 1,nrhs
            call ma57dd(job,matrix%n,matrix%ne,matrix%val,matrix%row, &
              matrix%col,factors%val,size(factors%val),factors%iw, &
              size(factors%iw),x(:,i), &
              start(:,i),resid,work,iwork,icntl,cntl,info,rinfo)
            enddo
            x = start
          else
            job=1
            call ma57cd(job,factors%n,factors%val,size(factors%val), &
              factors%iw,size(factors%iw),nrhs,x,size(x,1),   &
              work,nrhs*matrix%n,iwork,icntl,info)
          end if
        end if
      endif

      if (info(1) == -8 .or. info(1) == -14) sinfo%flag = -11

      deallocate (iwork,work,resid,stat=stat)
      if (factors%static == 1 .and. .not. present(rhs)) &
          deallocate (start,stat=stat)
      if (stat==0) return

  100 if (control%ldiag>0 .and. control%lp>0 )  &
          write (control%lp,'(/a/a,i5)') &
         'Error return from MA57_ANALYSE: flag = -3', &
         'Allocate or deallocate failed with STAT=',stat
      sinfo%flag = -3
      sinfo%stat = stat

   end subroutine ma57_solve2

   subroutine ma57_solve1(matrix,factors,x,control,sinfo,rhs,iter,cond)
      type(zd11_type), intent(in) :: matrix
      type(ma57_factors), intent(in) :: factors
      real(wp), intent(inout) :: x(:)
      type(ma57_control), intent(in) :: control
      type(ma57_sinfo), intent(out) :: sinfo
      real(wp), optional, intent(in) :: rhs(:)
      integer, optional, intent(in) :: iter
      integer, optional, intent(in) :: cond
      integer icntl(20),info(40),job,stat
      real(wp) cntl(5),rinfo(20),zero
      integer n,nrhs,lw

      integer, allocatable :: iwork(:)
      real(wp), allocatable :: work(:),resid(:),start(:)

      parameter (zero=0.0d0)

      n = matrix%n

      nrhs = 1

      stat = 0
      sinfo%flag = 0

! If rhs is present, then ma57dd will be called
! If iter is also present, then ADD algorithm is used
! If cond is also present, then condition number and error estimated

! lw is length of array work
      lw = n
      if (present(rhs))  lw = n
      if (present(iter)) lw = 3*n
      if (factors%static == 1) lw = 3*n
      if (present(cond)) lw = 4*n

      allocate (iwork(n),work(lw),resid(n),stat=stat)
      if (stat/=0) go to 100

      if (factors%static == 1 .and. .not. present(rhs)) &
          allocate(start(n),stat=stat)
      if (stat/=0) go to 100

      icntl(1) = control%lp
      icntl(2) = control%wp
      icntl(3) = control%mp
      icntl(4) = control%sp
      icntl(5) = control%ldiag
      icntl(13) = control%solveblocking
      icntl(15) = control%scaling

      cntl(3) = control%convergence

      stat = 0

      if (present(iter)) then
! If iter is present, then rhs must be also, and user must set x.
        icntl(9)=100
        icntl(10)=0
        if (present(cond)) icntl(10)=1
        job = 2
        call ma57dd(job,matrix%n,matrix%ne,matrix%val,matrix%row, &
          matrix%col,factors%val,size(factors%val),factors%iw, &
          size(factors%iw),rhs, &
          x,resid,work,iwork,icntl,cntl,info,rinfo)
        if (present(cond)) then
          sinfo%cond  = rinfo(11)
          sinfo%cond2 = rinfo(12)
          sinfo%berr  = rinfo(6)
          sinfo%berr2 = rinfo(7)
          sinfo%error = rinfo(13)
        endif
      else
        if(present(rhs)) then
          icntl(9) = 1
          icntl(10) = 0
          job = 2
          call ma57dd(job,matrix%n,matrix%ne,matrix%val,matrix%row, &
            matrix%col,factors%val,size(factors%val),factors%iw, &
            size(factors%iw),rhs, &
            x,resid,work,iwork,icntl,cntl,info,rinfo)
        else
          if (factors%static == 1) then
            icntl(9) = 1
            icntl(10) = 0
            job = 2
            start = zero
            call ma57dd(job,matrix%n,matrix%ne,matrix%val,matrix%row, &
              matrix%col,factors%val,size(factors%val),factors%iw, &
              size(factors%iw),x, &
              start,resid,work,iwork,icntl,cntl,info,rinfo)
            x = start
          else
            job=1
            call ma57cd(job,factors%n,factors%val,size(factors%val), &
              factors%iw,size(factors%iw),nrhs,x,size(x,1),   &
              work,nrhs*matrix%n,iwork,icntl,info)
          end if
        end if
      endif

      deallocate (iwork,work,resid,stat=stat)
      if (factors%static == 1 .and. .not. present(rhs))  &
          deallocate (start,stat=stat)
      if (stat==0) return

  100 if (control%ldiag>0 .and. control%lp>0 )  &
         write (control%lp,'(/a/a,i5)')  &
         'Error return from MA57_ANALYSE: flag = -3', &
         'Allocate or deallocate failed with STAT=',stat
      sinfo%flag = -3
      sinfo%stat = stat

   end subroutine ma57_solve1

   subroutine ma57_finalize(factors,control,info)
      type(ma57_factors), intent(inout) :: factors
      type(ma57_control), intent(in) :: control
      integer, intent(out) :: info
      integer :: inf

      info = 0
      inf = 0
      if (allocated(factors%keep)) deallocate(factors%keep,stat=inf)
      if (inf/=0) info = inf
      if (allocated(factors%iw)) deallocate(factors%iw,stat=inf)
      if (inf/=0) info = inf
      if (allocated(factors%val)) deallocate(factors%val,stat=inf)
      if (inf/=0) info = inf
      if (info==0) return

      if (control%ldiag>0 .and. control%lp>0 ) &
         write (control%lp,'(/a/a,i5)') &
         'Error return from MA57_FINALIZE:', &
         'Deallocate failed with STAT=',info

    end subroutine ma57_finalize

   subroutine ma57_enquire(factors,perm,pivots,d,perturbation,scaling)
      type(ma57_factors), intent(in) :: factors
      integer, intent(out), optional :: perm(factors%n),pivots(factors%n)
      real(wp), intent(out), optional :: d(2,factors%n)
      real(wp), intent(out), optional :: perturbation(factors%n)
      real(wp), intent(out), optional :: scaling(factors%n)

      real(wp) one,zero
      parameter (one=1.0d0,zero=0.0d0)

      integer block ! block index
      integer i     ! row index within the block
      integer ka    ! posn in array factors%val
      integer k2    ! posn in for off-diagonals of 2 x 2 pivots in factors%val
      integer kd    ! index in array d
      integer kp    ! index in array pivots
      integer kw    ! posn in array factors%iw
      integer ncols ! number of columns in the block
      integer nrows ! number of rows in the block
      logical two   ! flag for two by two pivots

      if(present(perm)) then
        perm = factors%keep(1:factors%n)
      endif

      if (present(perturbation)) then
        if (factors%pivoting == 4) then
          if (factors%scaling == 1) then
            perturbation = factors%val(size(factors%val) -  2*factors%n : &
                                       size(factors%val) -  factors%n -1)
          else
            perturbation = factors%val(size(factors%val) -  factors%n : &
                                       size(factors%val) - 1)
          endif
        else
          perturbation = zero
        end if
      endif


      if (present(scaling)) then
        if (factors%scaling == 1) then
          scaling = factors%val(size(factors%val) - factors%n : &
                                size(factors%val) - 1)
        else
          scaling = one
        end if
      endif

      if(present(pivots).or.present(d)) then
        ka = 1
        k2 = factors%iw(1)
        kd = 0
        kp = 0
        kw = 4
        if(present(d)) d = 0
          do block = 1, abs(factors%iw(3))
            ncols = factors%iw(kw)
            nrows = factors%iw(kw+1)
            if(present(pivots)) then
              pivots(kp+1:kp+nrows) = factors%iw(kw+2:kw+nrows+1)
              kp = kp + nrows
            end if
            if(present(d)) then
            two = .false.
            do i = 1,nrows
              kd = kd + 1
              d(1,kd) = factors%val(ka)
              if(factors%iw(kw+1+i)<0) two = .not.two
              if (two) then
                d(2,kd) = factors%val(k2)
                k2 = k2 + 1
              endif
              ka = ka + nrows + 1 - i
            end do
            ka = ka + nrows*(ncols-nrows)
          end if
          kw = kw + ncols + 2
        end do
      endif

   end subroutine ma57_enquire


   subroutine ma57_alter_d(factors,d,info)
      type(ma57_factors), intent(inout) :: factors
      real(wp), intent(in) :: d(2,factors%n)
      integer, intent(out) :: info

      integer block ! block index
      integer i     ! row index within the block
      integer ka    ! posn in array factors%val
      integer k2    ! posn in for off-diagonals of 2 x 2 pivots in factors%val
      integer kd    ! index in array d
      integer kw    ! posn in array factors%iw
      integer ncols ! number of columns in the block
      integer nrows ! number of rows in the block
      logical two   ! flag for two by two pivots

      info = 0
      ka = 1
      k2 = factors%iw(1)
      kd = 0
      kw = 4
      do block = 1, abs(factors%iw(3))
        ncols = factors%iw(kw)
        nrows = factors%iw(kw+1)
        two = .false.
        do i = 1,nrows
          kd = kd + 1
          factors%val(ka) = d(1,kd)
          if(factors%iw(kw+1+i)<0) two = .not.two
          if (two) then
            factors%val(k2) = d(2,kd)
            k2 = k2 + 1
          else
            if (d(2,kd) /= 0) info = kd
          end if
          ka = ka + nrows + 1 - i
        end do
        ka = ka + nrows*(ncols-nrows)
        kw = kw + ncols + 2
      end do

     end subroutine ma57_alter_d


   subroutine ma57_part_solve2(factors,control,part,x,info)
      type(ma57_factors), intent(in) :: factors
      type(ma57_control), intent(in) :: control
      character, intent(in) :: part
      real(wp), intent(inout) :: x(:,:)
      integer, intent(out) :: info
      integer icntl(20),n,nrhs,inf(40)

      integer, allocatable :: iwork(:)
      real(wp), allocatable :: work(:)

      n = factors%n

      nrhs = size(x,2)

      allocate (iwork(n),work(nrhs*n),stat=info)
      if (info/=0) go to 100

      icntl(1) = control%lp
      icntl(2) = control%wp
      icntl(3) = control%mp
      icntl(4) = control%sp
      icntl(5) = control%ldiag
      icntl(13) = control%solveblocking
      icntl(15) = control%scaling
      info = 0

      if(part=='L')then
         call ma57cd(2,factors%n,factors%val,size(factors%val),factors%iw, &
           size(factors%iw),nrhs,x,size(x,1),   &
           work,nrhs*factors%n,iwork,icntl,inf)
      else if(part=='D') then
         call ma57cd(3,factors%n,factors%val,size(factors%val),factors%iw, &
           size(factors%iw),nrhs,x,size(x,1),   &
           work,nrhs*factors%n,iwork,icntl,inf)
      else if(part=='U') then
         call ma57cd(4,factors%n,factors%val,size(factors%val),factors%iw, &
           size(factors%iw),nrhs,x,size(x,1),   &
           work,nrhs*factors%n,iwork,icntl,inf)
      end if


      deallocate (iwork,work,stat=info)
      if (info==0) return

  100 if (control%ldiag>0 .and. control%lp>0 )  &
          write (control%lp,'(/a/a,i5)') &
         'Error return from MA57_ANALYSE: flag = -3', &
         'Allocate or deallocate failed with STAT=',info

end subroutine ma57_part_solve2

   subroutine ma57_part_solve1(factors,control,part,x,info)
      type(ma57_factors), intent(in) :: factors
      type(ma57_control), intent(in) :: control
      character, intent(in) :: part
      real(wp), intent(inout) :: x(:)
      integer, intent(out) :: info
      integer inf(40),icntl(20),n,nrhs

      integer, allocatable :: iwork(:)
      real(wp), allocatable :: work(:)

      n = factors%n

      nrhs = 1

      allocate (iwork(n),work(n),stat=info)
      if (info/=0) go to 100

      icntl(1) = control%lp
      icntl(2) = control%wp
      icntl(3) = control%mp
      icntl(4) = control%sp
      icntl(5) = control%ldiag
      icntl(13) = control%solveblocking
      icntl(15) = control%scaling
      info = 0

      if(part=='L')then
         call ma57cd(2,factors%n,factors%val,size(factors%val),factors%iw, &
           size(factors%iw),nrhs,x,size(x,1),   &
           work,nrhs*factors%n,iwork,icntl,inf)
      else if(part=='D') then
         call ma57cd(3,factors%n,factors%val,size(factors%val),factors%iw, &
           size(factors%iw),nrhs,x,size(x,1),   &
           work,nrhs*factors%n,iwork,icntl,inf)
      else if(part=='U') then
         call ma57cd(4,factors%n,factors%val,size(factors%val),factors%iw, &
           size(factors%iw),nrhs,x,size(x,1),   &
           work,nrhs*factors%n,iwork,icntl,inf)
      end if


      deallocate (iwork,work,stat=info)
      if (info==0) return

  100 if (control%ldiag>0 .and. control%lp>0 ) &
          write (control%lp,'(/a/a,i5)') &
         'Error return from MA57_ANALYSE: flag = -3', &
         'Allocate or deallocate failed with STAT=',info

end subroutine ma57_part_solve1

end module hsl_ma57_double
! COPYRIGHT (c) 2006 Council for the Central Laboratory
!                    of the Research Councils
! This package may be copied and used in any application, provided no
! changes are made to these or any other lines.
! Original date 21 February 2006. Version 1.0.0.
! 6 March 2007 Version 1.1.0. Argument stat made non-optional

MODULE HSL_ZD11_double

!  ==========================
!  Sparse matrix derived type
!  ==========================

  TYPE, PUBLIC :: ZD11_type
    INTEGER :: m, n, ne
    CHARACTER, ALLOCATABLE, DIMENSION(:) :: id, type
    INTEGER, ALLOCATABLE, DIMENSION(:) :: row, col, ptr
    REAL ( KIND( 1.0D+0 ) ), ALLOCATABLE, DIMENSION(:) :: val
  END TYPE

CONTAINS

   SUBROUTINE ZD11_put(array,string,stat)
     CHARACTER, allocatable :: array(:)
     CHARACTER(*), intent(in) ::  string
     INTEGER, intent(OUT) ::  stat

     INTEGER :: i,l

     l = len_trim(string)
     if (allocated(array)) then
        deallocate(array,stat=stat)
        if (stat/=0) return
     end if
     allocate(array(l),stat=stat)
     if (stat/=0) return
     do i = 1, l
       array(i) = string(i:i)
     end do

   END SUBROUTINE ZD11_put

   FUNCTION ZD11_get(array)
     CHARACTER, intent(in):: array(:)
     CHARACTER(size(array)) ::  ZD11_get
! Give the value of array to string.

     integer :: i
     do i = 1, size(array)
        ZD11_get(i:i) = array(i)
     end do

   END FUNCTION ZD11_get

END MODULE HSL_ZD11_double


