!module handles command line arguments and provides initial and boundary conditions
module prep

    use schemes
    real :: fbound(2) !boundary conditions
    procedure(shock),pointer :: fexact  ! pointer to exact solution routine
    procedure(ftcs),pointer :: method   ! pointer to finite difference method

    contains

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! initial condition functions
    ! step
    subroutine shock(x,t,f,a)
        real x(:), f(:), a, t
        f = 0.5*(sign(1.0,x(:)-a*t)+1.0)
    end subroutine

    !gaussian distribution
    subroutine gauss(x,t,f,a)
        real x(:), f(:), a, t
        f = 0.5*exp(-(x-a*t)*(x-a*t))
    end subroutine



    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !! command line data extraction functions

    ! reads form argument and assigns pointer to exact solution procedure, arg 1
    subroutine read_exact(fexact,fbound,L,a)
        procedure(shock),pointer :: fexact
        real ::L,a
        character(len=5) :: arg
        real, dimension(2) :: fbound
        call get_command_argument(1,arg)
        if(arg .eq. 'shock') then
            fexact => shock
            print *,"use shock"
            fbound(1) = 0.d0
            fbound(2) = 1.d0

        else if(arg .eq. 'gauss') then
            fexact => gauss
            print *, "use gauss"
            fbound(1) = 0.d0
            fbound(2) = 0.d0

        end if
        L = 80.d0
        a = 1.5d0
    end subroutine

    ! reads form argument and assigns pointer to discrete scheme, arg 2
    subroutine read_scheme(method,arg)
        use schemes
        procedure(ftcs),pointer :: method
        character(len=16) :: arg
        call get_command_argument(2,arg)

        ! compare and assign section
        if(arg .eq. 'ftcs') then
            method => ftcs
        else if(arg .eq. 'upwind') then
            method => upwind
        else if(arg .eq. 'laxfr') then
            method => laxfriedrichs
        else if(arg .eq. 'laxwe') then
            method => laxwendroff
        else if(arg .eq. 'macco') then
            method => maccormack
        end if

        print *, "use ", arg
    end subroutine

    ! reads cfl number from arguments, arg 3
    subroutine read_CFL(CFL)
        character(len = 32) :: arg
        real :: CFL
        call get_command_argument(3,arg)
        read (arg,*) CFL
        print *, "CFL =", CFL
    end subroutine

    ! reads number of points, arg 4
    subroutine read_npoints(K)
        character(len = 16) :: arg
        integer :: K
        call get_command_argument(4,arg)
        read (arg,*) K
        print *, "K =", K
    end subroutine

    ! reads number of time steps, arg 5
    subroutine read_ntsteps(N)
        character(len = 16) :: arg
        integer :: N
        call get_command_argument(5,arg)
        read (arg,*) N
        print *, "N =", N
    end subroutine

    ! reads name of file to write output, arg 6
    subroutine read_ofname(ofname)
        character(len=64) :: ofname
        call get_command_argument(6,ofname)
    end subroutine

    ! reads name of file to write timing data, arg 7
    subroutine read_tofname(ofname)
        character(len=64) :: ofname
        call get_command_argument(7,ofname)
    end subroutine

end module prep
