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
% �������T Es,Eb �b�����(�n�|��)
SNR=10.^((SNRdB)/10);%Es
SNRb=1/8*(10.^((SNRdB)/10));%Eb
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
Mo = repmat(TX,1,8);
S(Mo>0)=1;S(Mo<=0)=-1;
for k = 1:11
% �������T Es-Eb�� SNR ��o��!!
noise=TXNUM/(2*SNRb(k));
% ����AWGN
n1 = sqrt(noise)*randn;
n2 = sqrt(noise)*randn;
n3 = sqrt(noise)*randn;
n4 = sqrt(noise)*randn;
n5 = sqrt(noise)*randn;
n6 = sqrt(noise)*randn;
n7 = sqrt(noise)*randn;
n8 = sqrt(noise)*randn;
AWGN = [n1,n2,n3,n4,n5,n6,n7,n8];
% �N���T�[�J��T��
Y = S + AWGN;
% �ѽX�ADemo���ѽX�᪺���G
D(Y>0)=1;D(Y<=0)=-1;
Demo(D>0)=1;Demo(D<0)=0;
% �έp�Z�����Y�A�èD�X�̤p�Z��
Dis1 = sum(abs(Y - [1,1,1,1,1,1,1,1]));
Dis2 = sum(abs(Y - [-1,-1,-1,-1,-1,-1,-1,-1]));
Distance = [Dis1,Dis2];
[minDis,Number] = min(Distance);
% �έp���~��bits�ơA��X���~�v�íp����~�v�M�T�������Y
if Dis1 == minDis
    RX = 1;
elseif Dis2 == minDis
    RX = 0;
end
Re = sum(abs(TX(1,1)- RX(1,1)));
% ���~�`bits��,�ðO���btotalE.
E = Re;
Error(k) = E;
end
Bits = Bits + Error; 
BER = Bits/(N);
end
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
semilogy(SNRdB,BER,'B-V',SNRdB,TheoryBER,'R-O');
grid on ;
legend('818','BPSK');
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for BCM code');
xlabel('Eb/N0');
ylabel('BER');
toc;