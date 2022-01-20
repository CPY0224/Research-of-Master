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
% 編碼，Mo為編碼後的結果
TX(a>0)=1;TX(a<=0)=0;
if sum(TX)==1||sum(TX)==3
    B = 1;
else
    B = 0;
end
Mo = [TX,B];
So(Mo>0)=1;So(Mo<=0)=-1;
for k = 1:11
% 產生雜訊 Es-Eb的 SNR 改這裡!!
noise=TXNUM/(2*SNRb(k));
% 產生AWGN
n1 = sqrt(noise)*randn;
n2 = sqrt(noise)*randn;
n3 = sqrt(noise)*randn;
n4 = sqrt(noise)*randn;
AWGN = [n1,n2,n3,n4];
% 將雜訊加入原訊號
Y = So + AWGN;
%Y1 = -1.2 ;Y2 = +0.8;Y3 = +0.4;Y4 = +0.7;
Y1 = Y(1,1);Y2 = Y(1,2);Y3 = Y(1,3);Y4 = Y(1,4);
% 第一個bit和1及-1的距離
A0 = sum(abs(Y1 - (-1))^2);
A1 = sum(abs(Y1 - 1)^2);
% 第二個bit和1及-1的距離
B0 = sum(abs(Y2 - (-1))^2);
B1 = sum(abs(Y2 - 1)^2);
% 第三個bit和1及-1的距離
C0 = sum(abs(Y3 - (-1))^2);
C1 = sum(abs(Y3 - 1)^2);
% 第四個bit和1及-1的距離
D0 = sum(abs(Y4 - (-1))^2);
D1 = sum(abs(Y4 - 1)^2);
% 將距離值表示成矩陣形式
% 開始Viterbi演算法的運算
% 第一個Bit的迴圈
AU = 0 + A0; AD = 0 + A1;
AS = [AU,AD]; [minAS,NUMAS] = min(AS);
% 第二個Bit的迴圈
BUU = AU + B0; BUD = AD + B1;
BDU = AU + B1; BDD = AD + B0;
BU = [BUU,BUD]; [minBU,NUMBU] = min(BU);
BD = [BDU,BDD]; [minBD,NUMBD] = min(BD);
% 第三個Bit的迴圈
CUU = minBU + C0; CUD = minBD + C1;
CDU = minBU + C1; CDD = minBD + C0;
CU = [CUU,CUD]; [minCU,NUMCU] = min(CU);
CD = [CDU,CDD]; [minCD,NUMCD] = min(CD);
% 第四個Bit的迴圈
DU = minCU + D0; DD = minCD + D1;
DF = [DU,DD]; [minDF,NUMDF] = min(DF);
% 將算出之值存成矩陣形式，其中100為虛設值，無任何作用
P = [AU BUU CUU DU;
    100 BUD CUD 100;
    100 BDU CDU 100;
     AD BDD CDD DD]; 
% 將最小值存成一個陣列
PM = [AU minBU minCU DU;
      AD minBD minCD DD];
% 開始判別這些值該走0還是1
if minDF == DU
    b4 = 0;
else
    b4 = 1;
end
if minCU == CUU
    bu3 = 0; 
else
    bu3 = 1;
end
if minCD == CDU
    bd3 = 1;
else
    bd3 = 0;
end
if minBU == BUU
    bu2 = 0;
else
    bu2 = 1;
end
if minBD == BDU
    bd2 = 1;
else
    bd2 = 0;
end
% 將判別過後的0或是1再存成一陣列
S = [0 bu2 bu3 b4
     1 bd2 bd3 100];
% 開始找最佳路徑，若遇到0直走遇到1斜走
if b4 == 0
    b3 = bu3;
else
    b3 = bd3;
end
if bu3 == 0
    b2 = bu2;
elseif bd2 == 1
    b2 = bd2;
elseif bu3 == 1
    b2 = bd2;
elseif bd2 == 0
    b2 = bd2;
end
if bu2 == 0 || bd2 == 1
    b1 = 0;
elseif bu2 == 1 || bd2 == 0
    b1 = 1;
end
Demo = [b1 b2 b3 b4];
% 解碼
% 再加上RX前，最佳路徑都能找出來，但是加上RX後，整個S陣列的值都會變1，現在卡在這出不來
RX = [b1 b2 b3];
% 統計錯誤的bits數，算出錯誤率並計算錯誤率和訊雜比的關係
Re = sum(abs(TX(1,3) - RX(1,3)));
E = Re;
Error(k) = E;
end
Bits = Bits + Error;
BER = Bits/N;
end
% semilogy函數可以使用y軸的對數刻度繪製數據
figure
semilogy(SNRdB,BER,'B-V',SNRdB,TheoryBER,'R-O');
grid on ;
legend('Viterbi','BPSK錯誤率理論值曲線');
% 將曲線圖之標題，X軸，Y軸各作標示
title('Curve for Viterbi');
xlabel('Eb/N0');
ylabel('BER');
toc;
