m = 8;           % Number of bits per symbol
n = 2^m - 1;     % Codeword length 
k = 127;         % Message length
x = randi([0 1],8,127);
msg = gf(x,m);
code = rsenc(msg,n,k);