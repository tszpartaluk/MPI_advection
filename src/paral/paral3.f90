!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
program advection


    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! include part
    use schemes
    use prep
    use paralrts
    implicit none
    include "mpif.h"




    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! declaration part

    

    ! K - number of grid points
    ! N - number of time steps
    ! s - number of points in process's domain
    ! i - iterator
    integer :: N,i,j,K
    
    ! L - domain width
    ! CFL - CFL number
    ! a - propagation speed
    real :: L,CFL,a
    character(len=64) :: ofname,tofname
    character(len=16) :: method_name

    ! x - point coordinates
    ! f1 - solution in 'previous' time step
    ! f2 - solution in 'actual' time step
    real, dimension(:), allocatable :: x
    real, dimension(:), allocatable :: f1
    real, dimension(:), allocatable :: f2

    ! parallel variables
    ! Kl - local grid size
    ! Kb - local grid bias
    ! Nbr - [left neigh, right neigh], negative values indicate boundary condition
    integer :: Kl
    integer :: Kb
    integer :: Klcomp
    integer, dimension(2) :: Nbr
    integer :: Merror,Mstatus
    integer :: Ptot,Ploc

    real,dimension(3) :: times
    real :: t0


    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! execution part






    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! MPI initialization
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    call MPI_INIT(Merror)


    t0 = 0.d0
    t0 =  MPI_WTIME()


    call MPI_COMM_SIZE(MPI_COMM_WORLD,Ptot,Merror)
    call MPI_COMM_RANK(MPI_COMM_WORLD,Ploc,Merror)



    ! obtain global values from commandline
    call read_exact(fexact,fbound,L,a)
    call read_scheme(method,method_name)
    call read_CFL(CFL)
    call read_ntsteps(N)
    call read_npoints(K)
    call read_ofname(ofname)
    call read_tofname(tofname)




    call split_domain(K,MPI_COMM_WORLD,Kb,Kl,Nbr)
    ! calculate necessary local computational grid size

    Klcomp = Kl
    do i=1,2,1
        if( Nbr(i) .ge. 0) then 
            Klcomp = Klcomp + 1
        end if
    end do

    

    ! allocate memory for data
    allocate(X(Klcomp))
    allocate(f1(Klcomp))
    allocate(f2(Klcomp))



    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! calculation part
    ! initialize solution
    ! set grid points location (or read mesh from file) - only used for initial condition calculation
    if( Nbr(1) .lt. 0) then
        j = 0   
    else 
        j = 1
    end if
    
    do i=1,Klcomp,1
        X(i) = -L/2.0 + L/(K-1)*(i+Kb-1-j)
    end do
    call fexact(x,0.0,f2,a)


    ! main time stepping loop
    call MPI_BARRIER(MPI_COMM_WORLD,Merror)

    times(1) = MPI_WTIME()-t0

    call method(MPI_COMM_WORLD,f1,f2,CFL,Klcomp,N,fbound,Nbr,times(3))
    times(2) = MPI_WTIME()-t0-times(1)
    ! calculate analytic solution in f1 to save memory
    call fexact(x,L*CFL*N/a/(K-1),f1,a)

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! save data to file
    call save(MPI_COMM_WORLD,ofname,X,f2,f1,Kl,Kb,Nbr)
    call save_stats(MPI_COMM_WORLD,CFL,K,N,times,method_name,tofname)
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! MPI TERMINATION
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    call MPI_FINALIZE(Merror)



    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! cleanup and program exit point

    !clear memory
    deallocate(x)
    deallocate(f1)
    deallocate(f2)


end program
