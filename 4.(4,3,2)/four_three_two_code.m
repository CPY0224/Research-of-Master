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
SNRb=3/4*(10.^((SNRdB)/10));
% BER�z�׭�
TheoryBER = 1/2*erfc(sqrt(SNR));
Bits = zeros(1,length(SNR));
for x = 1:N
a = randn(1,3);
% �s�X�AM���s�X�᪺���G
TX(a>0)=1;TX(a<=0)=0;
if sum(TX)==1||sum(TX)==3
    B = 1;
else
    B = 0;
end
Mo = [TX,B];
S(Mo>0)=1;S(Mo<=0)=-1;
    for k = 1:11
    % �������T Es-Eb�� SNR ��o��!!
    noise=TXNUM/(2*SNR(k));
    % ����AWGN
    n1 = sqrt(noise)*randn;
    n2 = sqrt(noise)*randn;
    n3 = sqrt(noise)*randn;
    n4 = sqrt(noise)*randn;
    AWGN = [n1,n2,n3,n4];
    % �N���T�[�J��T��
    Y = S + AWGN;
    % �ѽX�ADemo���ѽX�᪺���G
    D(Y>0)=1;D(Y<=0)=-1;
    Demo(D>0)=1;Demo(D<0)=0;
    % �έp�Z�����Y�A�èD�X�̤p�Z��
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
    % �έp���~��bits�ơA��X���~�v�íp����~�v�M�T�������Y
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
legend('(4,3,2)Soft decoding','BPSK���~�v�z�׭Ȧ��u');
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for (4,3,2) code');
xlabel('Es/N0');
ylabel('BER');
toc;