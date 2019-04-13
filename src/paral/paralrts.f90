module paralrts

contains

    subroutine distribute_points(K,P,Klocal,Kbias)
      implicit none
      integer :: K,P
      integer :: Klocal(:),Kbias(:)
      integer :: R,i,Ka

      ! decompose into whole and remaining part
      R = mod(K,P)
      Ka = (K-R)/P

      ! assign geid pts to processes
      do i=1,P,1
         if(i.le.R)then
            Klocal(i) = Ka+1
         else
            Klocal(i) = Ka
         end if
      end do

      ! calculate bias
      Kbias(1) = 0
      do i=2,P,1
         Kbias(i) = Kbias(i-1) + Klocal(i-1)
      end do
    end subroutine distribute_points



    subroutine split_domain(K,Mcomm,Kb,Kl,Nbr)
      implicit none
      integer :: Kb,Kl,Mcomm,K
      integer, dimension(2) :: Nbr
      integer :: Ploc,Ptot,Merror
      integer, dimension(:), allocatable :: Klocal
      integer, dimension(:), allocatable :: Kbias

      call MPI_COMM_SIZE(Mcomm,Ptot,Merror)
      call MPI_COMM_RANK(Mcomm,Ploc,Merror)
      

      allocate(Klocal(Ptot))
      allocate(Kbias(Ptot))


      ! distribution is deterministic, therefore it can be computed locally
      call distribute_points(K,Ptot,Klocal,Kbias)

      Kl = Klocal(Ploc+1)
      Kb = Kbias(Ploc+1)

      ! assign neighbours
      if(Ptot .eq. 1) then
         Nbr(1) = -1
         Nbr(2) = -2
      else
         if(Ploc .eq. 0) then
            Nbr(1) = -1
            Nbr(2) = 1
         else if(Ploc .eq. Ptot-1) then
            Nbr(1) = Ploc-1
            Nbr(2) = -2
         else
            Nbr(1) = Ploc-1
            Nbr(2) = Ploc+1
         end if
      end if

      deallocate(Klocal)
      deallocate(Kbias)

    end subroutine split_domain


    !save data to single file
    subroutine save(Mcomm,fname,x,f,fan,Kl,Kb,Nbr)
      implicit none
      include "mpif.h"
      character(len=64) :: fname
      real :: x(:), f(:), fan(:)
      integer :: Kl, Kb
      parameter rwidth = 24
      integer :: fhandle, Merror, Mcomm
      integer, dimension(2) :: Nbr

      integer :: Ploc,Ptot
      integer(kind=MPI_OFFSET_KIND) disp,recwidth
      integer :: i,start,fin
      integer :: status

      ! prepare buffer
      character(len=rwidth) :: buff
      character :: newline

      ! get communicator data
      call MPI_COMM_SIZE(Mcomm,Ptot,Merror)
      call MPI_COMM_RANK(Mcomm,Ploc,Merror)



      ! calculate displacement
      recwidth = 3*(rwidth+1)  ! line width (incl nextline char)
      disp = Kb*recwidth  ! number of lines in pr. * linewidth
      
      call MPI_BARRIER(Mcomm,Merror)
      

      ! open file in all procs.
      call MPI_FILE_OPEN(Mcomm,fname,MPI_MODE_WRONLY+MPI_MODE_CREATE,MPI_INFO_NULL,fhandle,Merror)

      ! set displacements
      call MPI_FILE_SET_VIEW(fhandle,disp,MPI_CHAR,MPI_CHAR,"native",MPI_INFO_NULL,Merror)
      
      start = -1
      fin = -1


      if (Nbr(1) .ge. 0) then
         start = 2   
      else 
         start = 1
      end if
      
      fin = start+Kl-1
      newline = NEW_LINE('A')
      
      ! write line by line
      do i=start,fin,1

         ! write point location
         write(buff,"(E24.16)") x(i)
         call MPI_FILE_WRITE(fhandle,buff,rwidth,MPI_CHAR,MPI_STATUS_IGNORE,Merror)

         ! write space
         write(buff,*) ' '
         call MPI_FILE_WRITE(fhandle,buff,1,MPI_CHAR,MPI_STATUS_IGNORE,Merror)

         ! write solution
         write(buff,"(E24.16)") f(i)
         call MPI_FILE_WRITE(fhandle,buff,rwidth,MPI_CHAR,MPI_STATUS_IGNORE,Merror)

         ! write space
         write(buff,*) ' '
         call MPI_FILE_WRITE(fhandle,buff,1,MPI_CHAR,MPI_STATUS_IGNORE,Merror)

         ! write analytic solution
         write(buff,"(E24.16)") fan(i)
         call MPI_FILE_WRITE(fhandle,buff,rwidth,MPI_CHAR,MPI_STATUS_IGNORE,Merror)


         ! write next line
         call MPI_FILE_WRITE(fhandle,newline,1,MPI_CHAR,MPI_STATUS_IGNORE,Merror)

      end do
      
      ! close file
      call MPI_FILE_CLOSE(fhandle,Merror)
    end subroutine save

    subroutine save_stats(Mcomm,CFL,K,N,times,metname,tofname)
      implicit none
      include "mpif.h"
      integer::Mcomm,K,N,Ploc,Ptot,Merror
      real::CFL
      real,dimension(3) :: times
      character(len=16) :: metname
      integer :: fhandle
      integer :: flag
      character(len=24) :: buff
      character(len=64) :: tofname
      character :: blank,newl

      call MPI_COMM_SIZE(Mcomm,Ptot,Merror)
      call MPI_COMM_RANK(Mcomm,Ploc,Merror)


      call MPI_BARRIER(Mcomm,Merror)


	if(Ploc .gt. 0) then
		call MPI_RECV(flag,1,MPI_INTEGER,Ploc-1,0,MComm,MPI_STATUS_IGNORE,Merror)
end if
	    ! write timing data to appended file
    	open(unit=1,file=tofname,access='APPEND')
    	write(1,"(A10,I8,I8,E24.16,I8,I8,E24.16,E24.16,E24.16)") metname,Ploc,Ptot,CFL,K,N,times(1),times(2),times(3)
    	close(1)
	if(Ploc .lt. Ptot-1) then
		call MPI_SEND(flag,1,MPI_INTEGER,Ploc+1,0,Mcomm,Merror)
	end if	


    end subroutine save_stats

end module paralrts
