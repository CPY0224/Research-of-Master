clc;
% 隨機產生整數，範圍0~1，取7位
a = randi([0,1],1,7);
% 把a加總起來後除2取餘數
b = mod(sum(a),2);
c(1,1:7) = a;
c(1,8) = b;
disp (['Data   : ' num2str(a)]);
disp (['bit    : ' num2str(b)]);
disp (['Encode : ' num2str(c)]);
