clc;
% �H�����;�ơA�d��0~1�A��7��
a = randi([0,1],1,7);
% ��a�[�`�_�ӫᰣ2���l��
b = mod(sum(a),2);
c(1,1:7) = a;
c(1,8) = b;
disp (['Data   : ' num2str(a)]);
disp (['bit    : ' num2str(b)]);
disp (['Encode : ' num2str(c)]);
