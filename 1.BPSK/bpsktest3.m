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
% 產生雜訊 Eb,Es 在此比較(要會算)
SNRb=10.^(SNRdB/10);
SNRs=10.^((SNRdB-3)/10);
% BER理論值
TheoryBER = 1/2*erfc(sqrt(SNRb));
Bits = zeros(1,length(SNRb));
for x = 1:N
a = randn;
% 編碼，Mo為編碼後的結果
if a>0
   Mo=1;
else
   Mo=0;
end
amo = 2*Mo-1;
    for k = 1:11
        % 產生雜訊 Es-Eb的 SNR 改這裡!!
        noise=TXNUM/(2*SNRb(k));
        % 產生AWGN
        n1 = sqrt(noise)*randn(1,1);
        % 將雜訊加入原訊號
        y=amo+n1;
        % 解碼，Demo為解碼後的結果
        if y>0
            Demo=1;
        else
            Demo=0;
        end
        % 統計錯誤的bits數，算出錯誤率並計算錯誤率和訊雜比的關係
        Re = sum(abs(Mo(1,1)- Demo(1,1)));
        %錯誤總bits數,並記錄在totalE.
        E = Re;
        Error(k) = E;
    end
Bits = Bits + Error;
BER = Bits/(N);
end
% semilogy函數可以使用y軸的對數刻度繪製數據
figure
semilogy(SNRdB,BER, 'B-V' ,SNRdB,TheoryBER, 'M-X' );
grid on ;
legend('錯誤率實驗值曲線' , '錯誤率理論值曲線');
% 將曲線圖之標題，X軸，Y軸各作標示
title('Curve for BER v.s SNR for QPSK modulation');
xlabel('SNRdB');
ylabel('BER');
toc;