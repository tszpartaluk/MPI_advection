# MPI_advection
This is simple demonstration of MPI usage in Fortran. It implements linear advection equation with differnt finite difference schemes.

## Arguments
Program takes 7 arguments in the folowing order

1. Initial condition 
2. Numerical scheme to use
3. CFL number
4. Number of grid points (including boundary points)
5. Number of time steps to perform
6. Output file for solution
7. Output file for timing

### Initial conditions
1. Shock wave - option `shock`
2. Gaussian bell - option `gauss`

### Schemes
1. FTCS - option `ftcs`
2. Upwind - option `upwind`
3. Lax–Friedrichs - option `laxfr`
3. Lax-Wendroff - option `laxwe`
3. MacCormack - option `macco`

## Compilation
Separate procedures are required for compilation of serial and parallel code.
### Serial code
Compilation of serial code is straightforward. `makefile` for `gfortran` is provided. In order to change compiler modification of `FC` variable should be sufficient. To compile go to `./src/serial` and run `make`. Binaries will be located in `.build/serial`.
To run program call for example:
```
./build/serial/serial shock upwind 0.5 100 100 solution.dat timing.dat
```

## Parallel Code
Compilation of MPI program is more complex.
