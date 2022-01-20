tic;
clc;
clear;
close all;
%2019/09/23 16:46 ���R�ק�
%�o�ӬO�ѦҥΡA�ۤv�A���@���A�ݤ����ݾǪ�
% ����10^6��bits�A�H����1�M-1
N=1000000;
% randn��Ʋ��ͱ`�A���G�����H����
%-�C�ӤH���@��--------------------------------------------------------------
%�]�wSNR_DB�d��1~10,�C1���@�I
SNR_DB=1:1:11;
%�ѽu�ƥ�
TXNUM=1;
%�������T EB,ES �b�����(�n�|��)
SNR=10.^(SNR_DB/10);
SNRs=10.^((SNR_DB-3)/10);
%BER�z�׭�
ber_th = (1/2)*erfc(sqrt(SNR));
%--------------------------------------------------------------------------
%���F�U���n��---------------------------------------------------------------
zzz=zeros(1,length(SNR));
%--------------------------------------------------------------------------
for x = 1:N/2
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
%�C�ӤH���@��--------------------------------------------------------------
%�������T Es-Eb�� SNR ��o��!!
noise=TXNUM/(2*SNR(k));
%����AWGN
n1 = sqrt(noise)*randn(1,1);
n2 = sqrt(noise)*randn(1,1);
%--------------------------------------------------------------------------
%�[�J��T��
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
%-�C�ӤH�ۤv�Q���A���|���@��-------------------------------------------------
bbb=sum(abs(Mo1(1,1)- Demo1(1,1)));%��
QQQ=sum(abs( Mo2(1,1)- Demo2(1,1)));%��
%���~�`bits��,�ðO���btotalE.
W=bbb+QQQ;
totalE(k)=W;
end
%�W�����]���s�x�}zzz
zzz=zzz+totalE;
ber=zzz/(N);
%--------------------------------------------------------------------------
end
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
x = 0:1:10 ;
semilogy(x,ber, 'B-V' ,x,ber_th, 'M-X' );
grid on ;
legend('���~�v����Ȧ��u' , '���~�v�z�׭Ȧ��u');
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for BER v.s SNR for QPSK modulation');
xlabel('SNRdB');
ylabel('BER');
toc;