tic;
clc;
clear;
close all;
%2019/09/23 16:46 楊昱修改
%這個是參考用，自己再打一次，看不懂問學長
% 產生10^6個bits，隨機的1和-1
N=1000000;
% randn函數產生常態分佈的偽隨機數
%-每個人都一樣--------------------------------------------------------------
%設定SNR_DB範圍1~10,每1取一點
SNR_DB=1:1:11;
%天線數目
TXNUM=1;
%產生雜訊 EB,ES 在此比較(要會算)
SNR=10.^(SNR_DB/10);
SNRs=10.^((SNR_DB-3)/10);
%BER理論值
ber_th = (1/2)*erfc(sqrt(SNR));
%--------------------------------------------------------------------------
%為了下面要用---------------------------------------------------------------
zzz=zeros(1,length(SNR));
%--------------------------------------------------------------------------
for x = 1:N/2
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
%每個人都一樣--------------------------------------------------------------
%產生雜訊 Es-Eb的 SNR 改這裡!!
noise=TXNUM/(2*SNR(k));
%產生AWGN
n1 = sqrt(noise)*randn(1,1);
n2 = sqrt(noise)*randn(1,1);
%--------------------------------------------------------------------------
%加入原訊號
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
%-每個人自己想的，都會不一樣-------------------------------------------------
bbb=sum(abs(Mo1(1,1)- Demo1(1,1)));%實
QQQ=sum(abs( Mo2(1,1)- Demo2(1,1)));%虛
%錯誤總bits數,並記錄在totalE.
W=bbb+QQQ;
totalE(k)=W;
end
%上面假設的零矩陣zzz
zzz=zzz+totalE;
ber=zzz/(N);
%--------------------------------------------------------------------------
end
% semilogy函數可以使用y軸的對數刻度繪製數據
figure
x = 0:1:10 ;
semilogy(x,ber, 'B-V' ,x,ber_th, 'M-X' );
grid on ;
legend('錯誤率實驗值曲線' , '錯誤率理論值曲線');
% 將曲線圖之標題，X軸，Y軸各作標示
title('Curve for BER v.s SNR for QPSK modulation');
xlabel('SNRdB');
ylabel('BER');
toc;