! module contains numerical schemes used in program
module schemes
    contains


    subroutine boundary(Mcomm,f1,f2,K,fbound,Nbr,tag)

        implicit none
        include "mpif.h"
        integer :: Mcomm,K,Merror
        !integer, dimension(MPI_STATUS_SIZE) :: Mstatus
        real :: f1(:),f2(:)
        real, dimension(2):: fbound
        integer,dimension(2):: Nbr
        integer :: tag
        integer :: Ploc


        
        call MPI_COMM_RANK(Mcomm,Ploc,Merror)
        !print*, Ploc,Nbr
        !! apply boundary condition, or exchange data with neighbor
        ! left boundary
        if(Nbr(1) .ge. 0) then
        ! send/recieve
        call MPI_SEND(f1(2),1,MPI_DOUBLE_PRECISION,Nbr(1),tag,Mcomm,Merror)
        call MPI_RECV(f1(1),1,MPI_DOUBLE_PRECISION,Nbr(1),tag,Mcomm,MPI_STATUS_IGNORE,Merror)

        else 
        ! apply boundary
        f2(1) = fbound(1)
        ! f1(1) has data from updated solution, with previous bc
        end if
        
        ! right boundary
        if(Nbr(2) .ge. 0) then
        ! send/recieve

        call MPI_SEND(f2(K-1),1,MPI_DOUBLE_PRECISION,Nbr(2),tag,Mcomm,Merror)
        call MPI_RECV(f1(K),1,MPI_DOUBLE_PRECISION,Nbr(2),tag,Mcomm,MPI_STATUS_IGNORE,Merror)

        else
        ! apply boundary
        f2(K) = fbound(2)
        end if
        
        
    end subroutine boundary
        

    
    subroutine upwind(Mcomm,f1,f2,c,K,N,fbound,Nbr,commtime)
        implicit none
        include "mpif.h"
        real :: f1(:), f2(:), c
        integer :: K,N
        real, dimension(2) :: fbound
        integer,dimension(2) :: Nbr
        real :: commtime,t1,t2
        integer :: Mcomm
        integer :: i

        commtime = 0.d0
        do i=1,N,1
        f1(1:K) = f2(1:K)
        !apply boundary condition/exchange interface data
        t1 = MPI_WTIME()
        call boundary(Mcomm,f1,f2,K,fbound,Nbr,i)
        t2 = MPI_WTIME()

        f2(2:K-1) = f1(2:K-1) - c*(f1(2:K-1) - f1(1:K-2))
        commtime=commtime+t2-t1
        end do
        
    end subroutine upwind

    subroutine ftcs(Mcomm,f1,f2,c,K,N,fbound,Nbr,commtime)
        implicit none
        include "mpif.h"
        real :: f1(:), f2(:), c
        integer :: K,N
        real, dimension(2) :: fbound
        integer,dimension(2) :: Nbr
        real :: commtime,t1,t2
        integer :: Mcomm
        integer :: i

        commtime = 0.d0
        do i=1,N,1
        f1(1:K) = f2(1:K)
        !apply boundary condition/exchange interface data
        t1 = MPI_WTIME()
        call boundary(Mcomm,f1,f2,K,fbound,Nbr,i)
        t2 = MPI_WTIME()

        f2(2:K-1) = f1(2:K-1) -0.5*c*(f1(3:K) - f1(1:K-2))
        commtime=commtime+t2-t1
        end do

    end subroutine ftcs


        
        
        
        subroutine laxfriedrichs(Mcomm,f1,f2,c,K,N,fbound,Nbr,commtime)
        implicit none
        include "mpif.h"
        real :: f1(:), f2(:), c
        integer :: K,N
        real, dimension(2) :: fbound
        integer,dimension(2) :: Nbr
        real :: commtime,t1,t2
        integer :: Mcomm
        integer :: i

        commtime = 0.d0
        do i=1,N,1
        f1(1:K) = f2(1:K)
        !apply boundary condition/exchange interface data
        t1 = MPI_WTIME()
        call boundary(Mcomm,f1,f2,K,fbound,Nbr,i)
        t2 = MPI_WTIME()
        f2(2:K-1) = 0.5*(1-c)*f1(3:K) +0.5*(1+c)*f1(1:K-2)
        commtime=commtime+t2-t1
        end do

    end subroutine laxfriedrichs



        
    subroutine laxwendroff(Mcomm,f1,f2,c,K,N,fbound,Nbr,commtime)
        implicit none
        include "mpif.h"
        real :: f1(:), f2(:), c
        integer :: K,N
        real, dimension(2) :: fbound
        integer,dimension(2) :: Nbr
        real :: commtime,t1,t2
        integer :: Mcomm
        integer :: i

        commtime = 0.d0
        do i=1,N,1
        f1(1:K) = f2(1:K)
        !apply boundary condition/exchange interface data
        t1 = MPI_WTIME()
        call boundary(Mcomm,f1,f2,K,fbound,Nbr,i)
        t2 = MPI_WTIME()
        f2(2:K-1) = (1-c*c)*f1(2:K-1) + 0.5*(c-1)*c*f1(3:K) +0.5*(c+1)*c*f1(1:K-2)
        commtime=commtime+t2-t1
        end do

    end subroutine  laxwendroff




        
    subroutine maccormack(Mcomm,f1,f2,c,K,N,fbound,Nbr,commtime)
        implicit none
        include "mpif.h"
        real :: f1(:), f2(:), c
        integer :: K,N
        real, dimension(2) :: fbound
        integer,dimension(2) :: Nbr
        real :: commtime,t1,t2,t3,t4
        integer :: Mcomm
        integer :: i
        real,dimension(:),allocatable::ft
        
        allocate(ft(K))
        commtime = 0.d0
        do i=1,N,1
        f1(1:K) = f2(1:K)
        !apply boundary condition/exchange interface data
        t1 = MPI_WTIME()
        call boundary(Mcomm,f1,ft,K,fbound,Nbr,i)
        t2 = MPI_WTIME()
        ft(2:K-1) = f1(2:K-1) - c*(f1(3:K) - f1(2:K-1))
        t3 = MPI_WTIME()
        f2=ft
        call boundary(Mcomm,ft,f2,K,fbound,Nbr,i)
        t4= MPI_WTIME()
        f2(2:K-1) = (f1(2:K-1)+ft(2:K-1))*0.5 - 0.5*c*(ft(2:K-1)-ft(1:K-2))
        
        commtime=commtime+t2-t1+t4-t3
        end do
        deallocate(ft)

    end subroutine maccormack

end module
