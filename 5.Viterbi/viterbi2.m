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
% �s�X�AMo���s�X�᪺���G
TX(a>0)=1;TX(a<=0)=0;
if sum(TX)==1||sum(TX)==3
    B = 1;
else
    B = 0;
end
Mo = [TX,B];
So(Mo>0)=1;So(Mo<=0)=-1;
for k = 1:11
% �������T Es-Eb�� SNR ��o��!!
noise=TXNUM/(2*SNRb(k));
% ����AWGN
n1 = sqrt(noise)*randn;
n2 = sqrt(noise)*randn;
n3 = sqrt(noise)*randn;
n4 = sqrt(noise)*randn;
AWGN = [n1,n2,n3,n4];
% �N���T�[�J��T��
Y = So + AWGN;
%Y1 = -1.2 ;Y2 = +0.8;Y3 = +0.4;Y4 = +0.7;
Y1 = Y(1,1);Y2 = Y(1,2);Y3 = Y(1,3);Y4 = Y(1,4);
% �Ĥ@��bit�M1��-1���Z��
A0 = sum(abs(Y1 - (-1))^2);
A1 = sum(abs(Y1 - 1)^2);
% �ĤG��bit�M1��-1���Z��
B0 = sum(abs(Y2 - (-1))^2);
B1 = sum(abs(Y2 - 1)^2);
% �ĤT��bit�M1��-1���Z��
C0 = sum(abs(Y3 - (-1))^2);
C1 = sum(abs(Y3 - 1)^2);
% �ĥ|��bit�M1��-1���Z��
D0 = sum(abs(Y4 - (-1))^2);
D1 = sum(abs(Y4 - 1)^2);
% �N�Z���Ȫ�ܦ��x�}�Φ�
% �}�lViterbi�t��k���B��
% �Ĥ@��Bit���j��
AU = 0 + A0; AD = 0 + A1;
AS = [AU,AD]; [minAS,NUMAS] = min(AS);
% �ĤG��Bit���j��
BUU = AU + B0; BUD = AD + B1;
BDU = AU + B1; BDD = AD + B0;
BU = [BUU,BUD]; [minBU,NUMBU] = min(BU);
BD = [BDU,BDD]; [minBD,NUMBD] = min(BD);
% �ĤT��Bit���j��
CUU = minBU + C0; CUD = minBD + C1;
CDU = minBU + C1; CDD = minBD + C0;
CU = [CUU,CUD]; [minCU,NUMCU] = min(CU);
CD = [CDU,CDD]; [minCD,NUMCD] = min(CD);
% �ĥ|��Bit���j��
DU = minCU + D0; DD = minCD + D1;
DF = [DU,DD]; [minDF,NUMDF] = min(DF);
% �N��X���Ȧs���x�}�Φ��A�䤤100����]�ȡA�L����@��
P = [AU BUU CUU DU;
    100 BUD CUD 100;
    100 BDU CDU 100;
     AD BDD CDD DD]; 
% �N�̤p�Ȧs���@�Ӱ}�C
PM = [AU minBU minCU DU;
      AD minBD minCD DD];
% �}�l�P�O�o�ǭȸӨ�0�٬O1
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
% �N�P�O�L�᪺0�άO1�A�s���@�}�C
S = [0 bu2 bu3 b4
     1 bd2 bd3 100];
% �}�l��̨θ��|�A�Y�J��0�����J��1�ר�
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
% �ѽX
% �A�[�WRX�e�A�̨θ��|�����X�ӡA���O�[�WRX��A���S�}�C���ȳ��|��1�A�{�b�d�b�o�X����
RX = [b1 b2 b3];
% �έp���~��bits�ơA��X���~�v�íp����~�v�M�T�������Y
Re = sum(abs(TX(1,3) - RX(1,3)));
E = Re;
Error(k) = E;
end
Bits = Bits + Error;
BER = Bits/N;
end
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
semilogy(SNRdB,BER,'B-V',SNRdB,TheoryBER,'R-O');
grid on ;
legend('Viterbi','BPSK���~�v�z�׭Ȧ��u');
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for Viterbi');
xlabel('Eb/N0');
ylabel('BER');
toc;