tic;
clc;
clear;
close all;
% 產生10^6個bits，隨機的1和0
N=1000000;
% randn函數產生常態分佈的偽隨機數
% 設定SNRdB範圍1~10,每1取一點
SNRdB=0:1:10;
% 天線數目
TXNUM=1;
% 產生雜訊 Es,Eb 在此比較(要會算)
SNR=10.^((SNRdB)/10);%Es
SNRb=1/8*(10.^((SNRdB)/10));%Eb
% BER理論值
TheoryBER = 1/2*erfc(sqrt(SNR));
Bits = zeros(1,length(SNR));
for x = 1:N
a = randn;
% 編碼，M為編碼後的結果
if a > 0
   TX = 1;
else
   TX = 0;
end
Mo = repmat(TX,1,8);
S(Mo>0)=1;S(Mo<=0)=-1;
for k = 1:11
% 產生雜訊 Es-Eb的 SNR 改這裡!!
noise=TXNUM/(2*SNRb(k));
% 產生AWGN
n1 = sqrt(noise)*randn;
n2 = sqrt(noise)*randn;
n3 = sqrt(noise)*randn;
n4 = sqrt(noise)*randn;
n5 = sqrt(noise)*randn;
n6 = sqrt(noise)*randn;
n7 = sqrt(noise)*randn;
n8 = sqrt(noise)*randn;
AWGN = [n1,n2,n3,n4,n5,n6,n7,n8];
% 將雜訊加入原訊號
Y = S + AWGN;
% 解碼，Demo為解碼後的結果
D(Y>0)=1;D(Y<=0)=-1;
Demo(D>0)=1;Demo(D<0)=0;
% 統計距離關係，並求出最小距離
Dis1 = sum(abs(Y - [1,1,1,1,1,1,1,1]));
Dis2 = sum(abs(Y - [-1,-1,-1,-1,-1,-1,-1,-1]));
Distance = [Dis1,Dis2];
[minDis,Number] = min(Distance);
% 統計錯誤的bits數，算出錯誤率並計算錯誤率和訊雜比的關係
if Dis1 == minDis
    RX = 1;
elseif Dis2 == minDis
    RX = 0;
end
Re = sum(abs(TX(1,1)- RX(1,1)));
% 錯誤總bits數,並記錄在totalE.
E = Re;
Error(k) = E;
end
Bits = Bits + Error; 
BER = Bits/(N);
end
% semilogy函數可以使用y軸的對數刻度繪製數據
figure
semilogy(SNRdB,BER,'B-V',SNRdB,TheoryBER,'R-O');
grid on ;
legend('818','BPSK');
% 將曲線圖之標題，X軸，Y軸各作標示
title('Curve for BCM code');
xlabel('Eb/N0');
ylabel('BER');
toc;
