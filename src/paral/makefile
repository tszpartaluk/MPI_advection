#Serial Make system

BIN = ./../../build/paral/
SRC = ./
MPIDIR := D:/ProgramFiles(x86)/Microsoft SDKs/MPI
MPIINCLUDE := -I "$(MPIDIR)/Include" -I "$(MPIDIR)/Include/x64"
MPILIB := -L "$(MPIDIR)/Lib/x64"


FC = gfortran
FFLAGS = -Wunused-variable -lmsmpi -fno-range-check -J $(BIN) $(MPIINCLUDE) $(MPILIB)

OBJECTS	:= paral3.o paralrts.o prep.o schemes.o
OBJECTS := $(addprefix $(BIN), $(OBJECTS))

$(BIN)paral3.exe: $(OBJECTS) $(BIN)mpi.mod
	$(FC) $(FFLAGS) $^ -o $@

$(BIN)paral3.o: $(SRC)paral3.f90 $(BIN)schemes.o $(BIN)prep.o $(BIN)paralrts.o $(BIN)mpi.mod
	$(FC) $(FFLAGS) -c $< -o $@ 

$(BIN)paralrts.o: $(SRC)paralrts.f90 $(BIN)mpi.mod
	$(FC) $(FFLAGS) -c $< -o $@ 

$(BIN)prep.o: $(SRC)prep.f90 $(BIN)mpi.mod
	$(FC) $(FFLAGS) -c $< -o $@ 

$(BIN)schemes.o: $(SRC)schemes.f90 $(BIN)mpi.mod
	$(FC) $(FFLAGS) -c $< -o $@ 

$(BIN)mpi.mod: '$(MPIDIR)/Include/mpi.f90'
	$(FC) $(FFLAGS) -D_WIN64 -D INT_PTR_KIND()=8 -c $< -o $(BIN)mpi.o