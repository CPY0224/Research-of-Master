tic;
clc;
clear;
close all;
% 產生10^6個bits，隨機的1和-1
N=10^6;
% randn函數產生常態分佈的偽隨機數
for x = 1:N
a(x) = randn;
b(x) = randn;
end
Si = a+b*1i;
% 編碼，Mo為編碼後的結果
if a>0
   Mo1=1;
else
   Mo1=0;
end
if b>0
   Mo2=1;
else
   Mo2=0;
end
amo = 2*Mo1-1;
bmo = 2*Mo2-1;
So = amo+bmo*1i;
% 產生高斯白噪聲
% 訊雜比範圍1~10,每1取一點
SNRdB=0:1:10;
% 訊雜比轉化為線性值
SNR=(10.^((SNRdB-3)/10));
% 針對以上的情況的11種訊雜比加入AWGN
% sigma函數相當於sum(1:11)
for k = 1:11
    sigma = sqrt(1/(2*SNR(k)));
for x = 1:N
n1(x)=sigma*a(x);
n2(x)=sigma*b(x);
y1(x)=amo+n1(x);
y2(x)=bmo+n2(x);
Wi=y1(x)+y2(x)*1j;
D(x)=abs((y1(x)-amo)+(y2(x)-bmo));
end
% 解碼，Demo為解碼後的結果
Bits(k) = 0;
for x = 1:N
    if y1(x)>0
        Demo1=1;
    else
        Demo1=0;
    end
    if y2(x)>0
        Demo2=1;
    else
        Demo2=0;
    end
ademo=2*Demo1-1;
bdemo=2*Demo2-1;
Wo = ademo+bdemo*1j;
% 統計錯誤的bits數，算出錯誤率並計算錯誤率和訊雜比的關係
if  ademo ~= amo
    Bits(k) = Bits(k)+1;
elseif bdemo ~= bmo
    Bits(k) = Bits(k)+1;
end
end
    BER(k) = (Bits(k)*1/2)/N;
    TheoryBER(k) = 1/2*erfc(sqrt(10.^(SNRdB(k)/10)));
end
% semilogy函數可以使用y軸的對數刻度繪製數據
figure
semilogy(SNRdB,BER, 'B-V' ,SNRdB,TheoryBER, 'M-X' );
grid on ;
legend('錯誤率實驗值曲線' , '錯誤率理論值曲線');
% 將曲線圖之標題，X軸，Y軸各作標示
title('Curve for BER v.s SNR for QPSK modulation');
xlabel('Es/N0');
ylabel('BER');
toc;