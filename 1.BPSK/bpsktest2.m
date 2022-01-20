tic;
clc;
clear;
close all;
% ����10^6��bits�A�H����1�M-1
N=10^6;
% randn��Ʋ��ͱ`�A���G�����H����
a = randn;
% �s�X�AMo���s�X�᪺���G
if randn>0
   Mo=1;
else
   Mo=0;
end
S=2*Mo-1;
% ���Ͱ����վ��n
% �T����d��1~10,�C1���@�I
SNRdB=0:1:10;
% �T������Ƭ��u�ʭ�
SNR=10.^(SNRdB/10);
% �w��H�W�����p��11�ذT����[�JAWGN
for k = 1:11
    sigma = sqrt(1/(2*SNR(k))); % sigma(j)��Ƭ۷��sum(1:11)
for i=1:N
    n(i)=sigma*randn;
    y(i)=S+n(i); % Mo(i)�O��J���X�An(i)�����n
end
% �ѽX�Ademo���ѽX�᪺���G
Bits(k) = 0;
for i=1:N
    if y(i) > 0
      Demo(i)=1;
    else
      Demo(i)=0;
    end
W=2*Demo(i)-1;
% �έp���~��bits�ơA��X���~�v�íp����~�v�M�T�������Y
if  W ~= S
    Bits(k) = Bits(k)+1;
end
end
    BER(k) = Bits(k)/N;
    TheoryBER(k) = 1/2*erfc(sqrt(10.^(SNRdB(k)/10)));
end
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
semilogy(SNRdB,BER, 'B-V' ,SNRdB,TheoryBER, 'M-X' );
grid on ;
legend('���~�v����Ȧ��u' , '���~�v�z�׭Ȧ��u');
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for BER v.s SNR for BPSK modulation');
xlabel('SNRdB');
ylabel('BER');
toc;