tic;
clc;
clear;
close all;
% ����10^6��bits�A�H����1�M0
N=1000000;
% randn��Ʋ��ͱ`�A���G�����H����
% �]�wSNRdB�d��1~10,�C1���@�I
SNRdB=0:1:10;
% �ѽu�ƥ�
TXNUM=1;
% �������T Es,Eb �b�����(�n�|��)�AQPSK��313�᪺ Eb,Es �ۤ�
SNR=10.^(SNRdB/10);%Eb
SNRb=1/2*(10.^((SNRdB)/10));%Es
% BER�z�׭�
TheoryBER = 1/2*erfc(sqrt(SNR));
Bits = zeros(1,length(SNR));
for x = 1:0.5*N
a = randn;
b = randn;
Si = a+b*1i;
% �s�X�AMo���s�X�᪺���G
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
    % �������T Es-Eb�� SNR ��o��!!
    noise=TXNUM/(2*SNR(k));
    % ����AWGN
    n1 = sqrt(noise)*randn(1,1);
    n2 = sqrt(noise)*randn(1,1);
    % �N���T�[�J��T��
    y1=amo+n1;
    y2=bmo+n2;
    Wi=y1+y2*1j;
    % �ѽX�ADemo���ѽX�᪺���G
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
    % �έp���~��bits�ơA��X���~�v�íp����~�v�M�T�������Y
    Re = sum(abs(Mo1(1,1)- Demo1(1,1)));
    Im = sum(abs(Mo2(1,1)- Demo2(1,1)));
    %���~�`bits��,�ðO���btotalE.
    E = Re + Im;
    Error(k) = E;
    end
Bits = Bits + Error;
BER = Bits/(N);
end
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
semilogy(SNRdB,BER, 'B-V' ,SNRdB,TheoryBER, 'M-X' );
grid on ;
legend('QPSK' , 'BPSK');
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for BER v.s SNR for QPSK modulation');
xlabel('Eb/N0');
ylabel('BER');
toc;