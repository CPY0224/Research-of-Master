tic;
clc;
clear;
close all;
% 產生10^6個bits，隨機的1和-1
N=10^6;
% randn函數產生常態分佈的偽隨機數
a = randn;
% 編碼，Mo為編碼後的結果
if randn>0
   Mo=1;
else
   Mo=0;
end
S=2*Mo-1;
% 產生高斯白噪聲
% 訊雜比範圍1~10,每1取一點
SNRdB=0:1:10;
% 訊雜比轉化為線性值
SNR=10.^(SNRdB/10);
% 針對以上的情況的11種訊雜比加入AWGN
for k = 1:11
    sigma = sqrt(1/(2*SNR(k))); % sigma(j)函數相當於sum(1:11)
for i=1:N
    n(i)=sigma*randn;
    y(i)=S+n(i); % Mo(i)是輸入的碼，n(i)為噪聲
end
% 解碼，demo為解碼後的結果
Bits(k) = 0;
for i=1:N
    if y(i) > 0
      Demo(i)=1;
    else
      Demo(i)=0;
    end
W=2*Demo(i)-1;
% 統計錯誤的bits數，算出錯誤率並計算錯誤率和訊雜比的關係
if  W ~= S
    Bits(k) = Bits(k)+1;
end
end
    BER(k) = Bits(k)/N;
    TheoryBER(k) = 1/2*erfc(sqrt(10.^(SNRdB(k)/10)));
end
% semilogy函數可以使用y軸的對數刻度繪製數據
figure
semilogy(SNRdB,BER, 'B-V' ,SNRdB,TheoryBER, 'M-X' );
grid on ;
legend('錯誤率實驗值曲線' , '錯誤率理論值曲線');
% 將曲線圖之標題，X軸，Y軸各作標示
title('Curve for BER v.s SNR for BPSK modulation');
xlabel('SNRdB');
ylabel('BER');
toc;