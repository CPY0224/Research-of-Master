%�]�wSNR_DB�d��1~10,�C1���@�I
SNRdB=0:1:10;
%�ѽu�ƥ�
TXNUM=1;
%�������T
SNR=10.^(SNRdB/10);
%�������T
noise=TXNUM/(2*SNR(k));
%����AWGN
AWGN = sqrt(noise)*randn(1,N);
% �C�ӤH�ۤv�Q���A���|���@��------------------------------------------------
zzz=zeros(1,length(SNR));
bbb=sum(abs(Mo1(1,1)- Demo1(1,1)));%��
QQQ=sum(abs( Mo2(1,1)- Demo2(1,1)));%��
% ���~�`bits��,�ðO���bBits.
W=bbb+QQQ;
Bits(k)=W;
end
%�W�����]���s�x�}zzz
zzz=zzz+Bits;
ber=zzz/(N);