clc;
a = randi([0,1],1,3);
b = mod(sum(a),2);
c(1,1:3) = a;
c(1,4) = b;
disp (['Data   : ' num2str(a)]);
disp (['bit P  : ' num2str(b)]);
disp (['Encode : ' num2str(c)]);
