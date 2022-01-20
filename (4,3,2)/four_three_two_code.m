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
SNR=10.^((SNRdB)/10);
SNRb=3/4*(10.^((SNRdB)/10));
% BER理論值
TheoryBER = 1/2*erfc(sqrt(SNR));
Bits = zeros(1,length(SNR));
for x = 1:N
a = randn(1,3);
% 編碼，M為編碼後的結果
TX(a>0)=1;TX(a<=0)=0;
if sum(TX)==1||sum(TX)==3
    B = 1;
else
    B = 0;
end
Mo = [TX,B];
S(Mo>0)=1;S(Mo<=0)=-1;
    for k = 1:11
    % 產生雜訊 Es-Eb的 SNR 改這裡!!
    noise=TXNUM/(2*SNR(k));
    % 產生AWGN
    n1 = sqrt(noise)*randn;
    n2 = sqrt(noise)*randn;
    n3 = sqrt(noise)*randn;
    n4 = sqrt(noise)*randn;
    AWGN = [n1,n2,n3,n4];
    % 將雜訊加入原訊號
    Y = S + AWGN;
    % 解碼，Demo為解碼後的結果
    D(Y>0)=1;D(Y<=0)=-1;
    Demo(D>0)=1;Demo(D<0)=0;
    % 統計距離關係，並求出最小距離
    Dis1 = sum(abs(Y - [-1,-1,-1,-1]));
    Dis2 = sum(abs(Y - [-1,-1,+1,+1]));
    Dis3 = sum(abs(Y - [-1,+1,-1,+1]));
    Dis4 = sum(abs(Y - [-1,+1,+1,-1]));
    Dis5 = sum(abs(Y - [+1,-1,-1,+1]));
    Dis6 = sum(abs(Y - [+1,-1,+1,-1]));
    Dis7 = sum(abs(Y - [+1,+1,-1,-1]));
    Dis8 = sum(abs(Y - [+1,+1,+1,+1]));
    Distance = [Dis1,Dis2,Dis3,Dis4,Dis5,Dis6,Dis7,Dis8];
    [minDis,Number] = min(Distance);
    % 統計錯誤的bits數，算出錯誤率並計算錯誤率和訊雜比的關係
    if Dis1 == minDis
        RX = [0,0,0];
    elseif Dis2 == minDis
        RX = [0,0,1];
    elseif Dis3 == minDis
        RX = [0,1,0];
    elseif Dis4 == minDis
        RX = [0,1,1];
    elseif Dis5 == minDis
        RX = [1,0,0];
    elseif Dis6 == minDis
        RX = [1,0,1];
    elseif Dis7 == minDis
        RX = [1,1,0];
    elseif Dis8 == minDis
        RX = [1,1,1];
    end
    Re = sum(abs(TX(1,3)- RX(1,3)));
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
legend('(4,3,2)Soft decoding','BPSK錯誤率理論值曲線');
% 將曲線圖之標題，X軸，Y軸各作標示
title('Curve for (4,3,2) code');
xlabel('Es/N0');
ylabel('BER');
toc;
