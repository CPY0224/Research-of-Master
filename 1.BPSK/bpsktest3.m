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
SNRb=10.^(SNRdB/10);
SNRs=10.^((SNRdB-3)/10);
% BER�z�׭�
TheoryBER = 1/2*erfc(sqrt(SNRb));
Bits = zeros(1,length(SNRb));
for x = 1:N
a = randn;
% �s�X�AMo���s�X�᪺���G
if a>0
   Mo=1;
else
   Mo=0;
end
amo = 2*Mo-1;
    for k = 1:11
        % �������T Es-Eb�� SNR ��o��!!
        noise=TXNUM/(2*SNRb(k));
        % ����AWGN
        n1 = sqrt(noise)*randn(1,1);
        % �N���T�[�J��T��
        y=amo+n1;
        % �ѽX�ADemo���ѽX�᪺���G
        if y>0
            Demo=1;
        else
            Demo=0;
        end
        % �έp���~��bits�ơA��X���~�v�íp����~�v�M�T�������Y
        Re = sum(abs(Mo(1,1)- Demo(1,1)));
        %���~�`bits��,�ðO���btotalE.
        E = Re;
        Error(k) = E;
    end
Bits = Bits + Error;
BER = Bits/(N);
end
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
semilogy(SNRdB,BER, 'B-V' ,SNRdB,TheoryBER, 'M-X' );
grid on ;
legend('���~�v����Ȧ��u' , '���~�v�z�׭Ȧ��u');
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for BER v.s SNR for QPSK modulation');
xlabel('SNRdB');
ylabel('BER');
toc;