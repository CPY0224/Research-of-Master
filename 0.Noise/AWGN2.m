% ���Ͱ����վ��n�Arandn ��Ʋ���10^6�ӥ��A���G�����H����
b=randn(1,N);
% �H����d��1~10,�C1���@�I
SNRdB=0:1:10;
% �w��H�W�����p��11�ثH����[�J�վ��n
for j = 1:11
    sigma(j) = power(10,(-SNRdB(j)/20))/sqrt(2); % sigma(j)��Ƭ۷��sum(1:11)
for i = 1:N
    n(i)=sigma(j)*b(i);
    y(i)=Mo(i)+n(i); % Mo(i)�O��J���X�An(i)�����n
end