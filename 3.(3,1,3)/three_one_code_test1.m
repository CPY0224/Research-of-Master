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
% �������T Eb,Es �b�����(�n�|��)
SNR=10.^((SNRdB)/10); 
SNRb=1/3*(10.^((SNRdB)/10));
% BER�z�׭�
TheoryBER = 1/2*erfc(sqrt(SNR));
Bits = zeros(1,length(SNR));
for x = 1:N
a = randn;
% �s�X�AM���s�X�᪺���G
if a > 0
   TX = 1;
else
   TX = 0;
end
Mo = repmat(TX,1,3);
S(Mo>0)=1;S(Mo<=0)=-1;
    for k = 1:11
    % �������T Es-Eb�� SNR ��o��!!
    noise=TXNUM/(2*SNR(k));
    % ����AWGN
    n1 = sqrt(noise)*randn;
    n2 = sqrt(noise)*randn;
    n3 = sqrt(noise)*randn;
    AWGN = [n1,n2,n3];
    % �N���T�[�J��T��
    Y = S + AWGN;
    % �ѽX�ADemo���ѽX�᪺���G
    D(Y>0)=1;D(Y<=0)=-1;
    Demo(D>0)=1;Demo(D<0)=0;
    % �έp���~��bits�ơA��X���~�v�íp����~�v�M�T�������Y;
    Z = sum(Demo);
    if Z >= 2
        RX = 1;
    else
        RX = 0;
    end
    % �έp���~��bits�ơA��X���~�v�íp����~�v�M�T�������Y
    Re = sum(abs(TX(1,1)- RX(1,1)));
    %���~�`bits��,�ðO���btotalE.
    E = Re;
    Error(k) = E;
    end
Bits = Bits + Error;
BER = Bits/(N);
end
Ber = [0.00792500000000000,0.00326600000000000,0.00104200000000000,0.000257000000000000,4.70000000000000e-05,1.10000000000000e-05,0,0,0,0,0];
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
semilogy(SNRdB,Ber,'G-S',SNRdB,BER,'B-V',SNRdB,TheoryBER,'R-O');
grid on ;
legend('(3,1)Soft decoding','(3,1)Hard decoding','BPSK���~�v�z�׭Ȧ��u');
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for (3,1) code');
xlabel('Es/N0');
ylabel('BER');
toc;