%設定SNR_DB範圍1~10,每1取一點
SNRdB=0:1:10;
%天線數目
TXNUM=1;
%產生雜訊
SNR=10.^(SNRdB/10);
%產生雜訊
noise=TXNUM/(2*SNR(k));
%產生AWGN
AWGN = sqrt(noise)*randn(1,N);
% 每個人自己想的，都會不一樣------------------------------------------------
zzz=zeros(1,length(SNR));
bbb=sum(abs(Mo1(1,1)- Demo1(1,1)));%實
QQQ=sum(abs( Mo2(1,1)- Demo2(1,1)));%虛
% 錯誤總bits數,並記錄在Bits.
W=bbb+QQQ;
Bits(k)=W;
end
%上面假設的零矩陣zzz
zzz=zzz+Bits;
ber=zzz/(N);