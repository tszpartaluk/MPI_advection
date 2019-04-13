clear

CFL = 0.5;
L = 80;
K = 100;
T = 5;
a = 1.5;

dx = L/(K-1);

N = ceil(T*a/CFL/dx)

C = a*T/dx/N

