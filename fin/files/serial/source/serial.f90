

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
program advection

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! include part
    use schemes
    use prep




    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! declaration part

    implicit none

    ! K - number of grid points
    ! N - number of time steps
    ! s - number of points in process's domain
    ! i - iterator
    integer :: K,N,i,s

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
    real, dimension(:), allocatable :: fan

    ! array to store timing data
    real, dimension(10) :: times


    call CPU_TIME(times(1))

    call read_exact(fexact,fbound,L,a)
    call read_scheme(method,method_name)
    call read_CFL(CFL)
    call read_npoints(K)
    call read_ntsteps(N)
    call read_ofname(ofname)
    call read_tofname(tofname)


    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! preprocessing

    !allocate values
    allocate(x(K))
    allocate(f1(K))
    allocate(f2(K))
    allocate(fan(K))


    ! set grid points location (or read mesh for file)
    do i=1,K,1
       x(i) = -L/2 + L/(K-1)*(i-1)
    end do

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! calculation part
    ! initialize solution
    call fexact(x,0.0,f2,a)

    call CPU_TIME(times(2))
    ! main time stepping loop
    do i = 1,N,1
        f1 = f2

        !! calculate
        call method(f1,f2,CFL,K,fbound)
        !! refresh data

    end do
    call CPU_TIME(times(3))




    call fexact(x,N*CFL*L/(K-1)/a,fan,a)


    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! postprocessing

    ! print results to file
    open(unit = 1,file=ofname)

    ! write to file loop
    do i=1,K,1
    write(1, "(3E24.16)" ) x(i),f2(i),fan(i)   ! numerical solution
    end do
    
    call CPU_TIME(times(4))

    close(1)

    ! write timing data to appended file
    open(unit=1,file=tofname,access='APPEND')
    write(1,"(A16,E24.16,I8,I8,3E24.16)") method_name,CFL,K,N,times(2)-times(1),times(3)-times(2),times(4)-times(3)
    close(1)

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! cleanup and program exit point

    !clear memory
    deallocate(x)
    deallocate(f1)
    deallocate(f2)


end
