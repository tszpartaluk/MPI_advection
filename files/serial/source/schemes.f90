! module contains numerical schemes used in program
module schemes
    contains
    subroutine ftcs(f1,f2,c,K,fbound)
        implicit none
        real f1(:), f2(:), c
        integer K
        real, dimension(2) :: fbound
	
	f2(1) = fbound(1)
	f2(K) = fbound(2)
        f2(2:K-1) = f1(2:K-1) - 0.5*c*(f1(3:K) - f1(1:K-2))
    end subroutine ftcs

    subroutine upwind(f1,f2,c,K,fbound)
        implicit none
        real f1(:), f2(:), c
        integer K
        real, dimension(2) :: fbound

	f2(1) = fbound(1)
	f2(K) = fbound(2)
        f2(2:K-1) = f1(2:K-1) - c*(f1(2:K-1) - f1(1:K-2))
    end subroutine upwind

    subroutine laxfriedrichs(f1,f2,c,K,fbound)
        implicit none
        real f1(:), f2(:), c
        integer K
        real, dimension(2) :: fbound
	f2(1) = fbound(1)
	f2(K) = fbound(2)

        f2(2:K-1) = 0.5*(1-c)*f1(3:K) +0.5*(1+c)*f1(1:K-2)
    end subroutine laxfriedrichs

    subroutine laxwendroff(f1,f2,c,K,fbound)
        implicit none
        real f1(:), f2(:), c
        integer K
        real, dimension(2) :: fbound
	f2(1) = fbound(1)
	f2(K) = fbound(2)

        f2(2:K-1) = (1-c*c)*f1(2:K-1) + 0.5*(c-1)*c*f1(3:K) +0.5*(c+1)*c*f1(1:K-2)
    end subroutine laxwendroff

    subroutine maccormack(f1,f2,c,K,fbound)
        implicit none
        real f1(:), f2(:), c
        integer K
        real, dimension(2) :: fbound

	f2(1) = fbound(1)
	f2(K) = fbound(2)
        !predictor step
        f2(2:K-1) = f1(2:K-1) - c*(f1(3:k)-f1(2:K-1))
        ! corrector step
        f2(2:K-1) = 0.5*(f1(2:K-1)+f2(2:K-1)) - 0.5*c*(f2(2:K-1)-f2(1:K-2))
    end subroutine maccormack

end module
