% 設定SNRdB範圍0~25,每1取一點  
SNRdB=0:1:25;
BER_HR  = ;
BER_212 =;
BER_213 =;
BER_214 =;
BER_215 =;
BER_216 =;
% semilogy函數可以使用y軸的對數刻度繪製數據
figure
semilogy(SNRdB,BER_HR, 'B-V',SNRdB,BER_212, 'R-S',SNRdB,BER_213, 'G-O');
grid on ;
legend('HRSTBC','(2,1,2)CC add HRSTBC','(2,1,3)CC add HRSTBC');
axis([0 25 10^-6 10^0]);
% 將曲線圖之標題，X軸，Y軸各作標示
title('Curve for BER v.s SNR for Convolution Codes and High Rate');
xlabel('Eb/N0');
ylabel('BER');