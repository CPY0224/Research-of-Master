% 產生高斯白噪聲，randn 函數產生10^6個正態分佈的偽隨機數
b=randn(1,N);
% 信噪比範圍1~10,每1取一點
SNRdB=0:1:10;
% 針對以上的情況的11種信噪比加入白噪聲
for j = 1:11
    sigma(j) = power(10,(-SNRdB(j)/20))/sqrt(2); % sigma(j)函數相當於sum(1:11)
for i = 1:N
    n(i)=sigma(j)*b(i);
    y(i)=Mo(i)+n(i); % Mo(i)是輸入的碼，n(i)為噪聲
end