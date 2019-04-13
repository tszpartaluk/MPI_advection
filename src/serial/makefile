#Serial Make system

BIN = ./../../build/serial/
SRC = ./

FC = gfortran
#FC = x86_64-w64-mingw32-gfortran.exe
FFLAGS = -Wunused-variable -J$(BIN)

OBJECTS	:= serial.o prep.o schemes.o
OBJECTS := $(addprefix $(BIN), $(OBJECTS))

$(BIN)serial.exe: $(OBJECTS)
	$(FC) $(FFLAGS) $^ -o $@ 

$(BIN)serial.o: $(SRC)serial.f90 $(BIN)schemes.o $(BIN)prep.o
	$(FC) $(FFLAGS) -c $< -o $@ 

$(BIN)prep.o: $(SRC)prep.f90
	$(FC) $(FFLAGS) -c $< -o $@ 

$(BIN)schemes.o: $(SRC)schemes.f90
	$(FC) $(FFLAGS) -c $< -o $@ 
