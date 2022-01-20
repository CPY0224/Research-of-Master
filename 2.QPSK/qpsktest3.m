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
% 產生雜訊 Es,Eb 在此比較(要會算)，QPSK跟313後的 Eb,Es 相反
SNR=10.^(SNRdB/10);%Eb
SNRb=1/2*(10.^((SNRdB)/10));%Es
% BER理論值
TheoryBER = 1/2*erfc(sqrt(SNR));
Bits = zeros(1,length(SNR));
for x = 1:0.5*N
a = randn;
b = randn;
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
    for k = 1:11
    % 產生雜訊 Es-Eb的 SNR 改這裡!!
    noise=TXNUM/(2*SNR(k));
    % 產生AWGN
    n1 = sqrt(noise)*randn(1,1);
    n2 = sqrt(noise)*randn(1,1);
    % 將雜訊加入原訊號
    y1=amo+n1;
    y2=bmo+n2;
    Wi=y1+y2*1j;
    % 解碼，Demo為解碼後的結果
    if y1>0
        Demo1=1;
    else
        Demo1=0;
    end
    if y2>0
        Demo2=1;
    else
        Demo2=0;
    end
    ademo=2*Demo1-1;
    bdemo=2*Demo2-1;
    Wo = ademo+bdemo*1j;
    % 統計錯誤的bits數，算出錯誤率並計算錯誤率和訊雜比的關係
    Re = sum(abs(Mo1(1,1)- Demo1(1,1)));
    Im = sum(abs(Mo2(1,1)- Demo2(1,1)));
    %錯誤總bits數,並記錄在totalE.
    E = Re + Im;
    Error(k) = E;
    end
Bits = Bits + Error;
BER = Bits/(N);
end
% semilogy函數可以使用y軸的對數刻度繪製數據
figure
semilogy(SNRdB,BER, 'B-V' ,SNRdB,TheoryBER, 'M-X' );
grid on ;
legend('QPSK' , 'BPSK');
% 將曲線圖之標題，X軸，Y軸各作標示
title('Curve for BER v.s SNR for QPSK modulation');
xlabel('Eb/N0');
ylabel('BER');
toc;