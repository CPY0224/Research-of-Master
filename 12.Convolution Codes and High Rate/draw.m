% �]�wSNRdB�d��0~25,�C1���@�I  
SNRdB=0:1:25;
BER_HR  = ;
BER_212 =;
BER_213 =;
BER_214 =;
BER_215 =;
BER_216 =;
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
semilogy(SNRdB,BER_HR, 'B-V',SNRdB,BER_212, 'R-S',SNRdB,BER_213, 'G-O');
grid on ;
legend('HRSTBC','(2,1,2)CC add HRSTBC','(2,1,3)CC add HRSTBC');
axis([0 25 10^-6 10^0]);
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for BER v.s SNR for Convolution Codes and High Rate');
xlabel('Eb/N0');
ylabel('BER');