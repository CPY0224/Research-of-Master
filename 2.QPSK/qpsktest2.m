tic;
clc;
clear;
close all;
% ����10^6��bits�A�H����1�M-1
N=10^6;
% randn��Ʋ��ͱ`�A���G�����H����
for x = 1:N
a(x) = randn;
b(x) = randn;
end
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
% ���Ͱ����վ��n
% �T����d��1~10,�C1���@�I
SNRdB=0:1:10;
% �T������Ƭ��u�ʭ�
SNR=(10.^((SNRdB-3)/10));
% �w��H�W�����p��11�ذT����[�JAWGN
% sigma��Ƭ۷��sum(1:11)
for k = 1:11
    sigma = sqrt(1/(2*SNR(k)));
for x = 1:N
n1(x)=sigma*a(x);
n2(x)=sigma*b(x);
y1(x)=amo+n1(x);
y2(x)=bmo+n2(x);
Wi=y1(x)+y2(x)*1j;
D(x)=abs((y1(x)-amo)+(y2(x)-bmo));
end
% �ѽX�ADemo���ѽX�᪺���G
Bits(k) = 0;
for x = 1:N
    if y1(x)>0
        Demo1=1;
    else
        Demo1=0;
    end
    if y2(x)>0
        Demo2=1;
    else
        Demo2=0;
    end
ademo=2*Demo1-1;
bdemo=2*Demo2-1;
Wo = ademo+bdemo*1j;
% �έp���~��bits�ơA��X���~�v�íp����~�v�M�T�������Y
if  ademo ~= amo
    Bits(k) = Bits(k)+1;
elseif bdemo ~= bmo
    Bits(k) = Bits(k)+1;
end
end
    BER(k) = (Bits(k)*1/2)/N;
    TheoryBER(k) = 1/2*erfc(sqrt(10.^(SNRdB(k)/10)));
end
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
semilogy(SNRdB,BER, 'B-V' ,SNRdB,TheoryBER, 'M-X' );
grid on ;
legend('���~�v����Ȧ��u' , '���~�v�z�׭Ȧ��u');
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for BER v.s SNR for QPSK modulation');
xlabel('Es/N0');
ylabel('BER');
toc;