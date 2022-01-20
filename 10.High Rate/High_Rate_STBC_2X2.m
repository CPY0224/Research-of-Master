tic;
clc;
clear;
close all;
% ����10^6��bits�A�H����1�M0
N=1000000;
% randn��Ʋ��ͱ`�A���G�����H����
% �]�wSNRdB�d��0~25,�C1���@�I
SNRdB=0:1:25;
% �ѽu�ƥ�
TXNUM=2;
% �������T Es,Eb �b�����(�n�|��)
SNR=10.^(SNRdB/10);%Es
SNRb=4*(10.^((SNRdB)/10));%Eb
% BER�z�׭�
BPSK = 1/2*erfc(sqrt(SNR));
Bits = zeros(1,length(SNR));
% �ݶ]�X��bits�A���H�X
B = 8;
% ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
% ���ͼзǤ��T��(256���G)
temp = zeros(255,8);
for kk = 1:1:255
    xor(kk,1) = bitxor(0,kk);% �G�i����Q�i��[�k�A��0�}�l�[�A�C���[1�A�[���ᬰ�Q�i��
    xor_char = dec2bin(xor);% �N�[���᪺�Q�i��Ʀr�A�ন�G�i��r��(char)
end
for rol = 1:1:255
    for col = 1:1:8
        temp(rol,col) = xor_char(rol,col) - '0';% �ѩ�ASCII�s�X�����Y�A�ݭn�0�~��N�r��(char)�ন���(int)
    end
end
% ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

% ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
% �зǤ��T��(256���G)
array = [0,0,0,0,0,0,0,0;temp];
% ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

% �}�lHigh Rate STBC 2X2�s��
for k = 1:26
    error_bits = 0;
    E = 0;
    for x = 1:(1/B)*N 
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        % �}�l�s�X�A���ͰT��
        s = randn(1,8);
        for xx = 1:1:8
            if s(1,xx) > 0
                si(1,xx) = 1;
            elseif s(1,xx) <= 0
                si(1,xx) = 0;
            end
            TX(1,xx) = 2*si(1,xx) - 1;
        end
        si1 = (1/sqrt(2))*(TX(1,1) + TX(1,2)*1i);
        si2 = (1/sqrt(2))*(TX(1,3) + TX(1,4)*1i);
        si3 = (1/sqrt(2))*(TX(1,5) + TX(1,6)*1i);
        si4 = (1/sqrt(2))*(TX(1,7) + TX(1,8)*1i);
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        % ����High Rate�T��
        theta1 = 63.4;
        theta2 = 90-theta1;
        high_rate_array = [si1*sind(theta1)-(conj(si2))*cosd(theta1),si3*sind(theta2)-(conj(si4))*cosd(theta2)
                          -(conj(si3))*sind(theta2)+si4*cosd(theta2),(conj(si1))*sind(theta1)-si2*cosd(theta1)];
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////                             

        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        % ���ͳq�D���T:Rayleigh fading channel
        sys_ray = sqrt(0.5)*(randn(1,4) + randn(1,4)*1i);
        % �N�p�Q�q�D�[�J�T��
        sys_ray_array = [sys_ray(1,1),sys_ray(1,2);sys_ray(1,3),sys_ray(1,4)];
        r_ray = high_rate_array*sys_ray_array;
        %/////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        %/////////////////////////////////////////////////////////////////////////////////////////////////////////
        % ����AWGN���T
        noise=TXNUM/(2*SNRb(k)); %�������T Es-Eb�� SNR ��o��!!
        % ����AWGN
        n = sqrt(noise)*randn(1,8);
        % �N���T�[�J�w�]�t�p�Q�q�D���T��
        AWGN_array = [n(1,1) + n(1,2)*1i,n(1,3) + n(1,4)*1i;n(1,5) + n(1,6)*1i,n(1,7) + n(1,8)*1i];
        r = r_ray + AWGN_array;
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        % �}�l�ѽX
        one = ones(256,8);
        array_signal = 2*array - one;
        for kkk = 1:1:256
            so1(kkk,:) = (1/sqrt(2))*[(array_signal(kkk,1) + array_signal(kkk,2)*1i)];
            so2(kkk,:) = (1/sqrt(2))*[(array_signal(kkk,3) + array_signal(kkk,4)*1i)];
            so3(kkk,:) = (1/sqrt(2))*[(array_signal(kkk,5) + array_signal(kkk,6)*1i)];
            so4(kkk,:) = (1/sqrt(2))*[(array_signal(kkk,7) + array_signal(kkk,8)*1i)];
            signal_one(kkk,1:2) = [so1(kkk,:)*sind(theta1)-(conj(so2(kkk,:)))*cosd(theta1),so3(kkk,:)*sind(theta2)-(conj(so4(kkk,:)))*cosd(theta2)];
            signal_two(kkk,1:2) = [-(conj(so3(kkk,:)))*sind(theta2)+so4(kkk,:)*cosd(theta2),conj(so1(kkk,:))*sind(theta1)-so2(kkk,:)*cosd(theta1)];
            signal(1:2,2*kkk-1:2*kkk) = [signal_one(kkk,1:2);signal_two(kkk,1:2)];
            signal_csi(1:2,2*kkk-1:2*kkk) = signal(1:2,2*kkk-1:2*kkk)*sys_ray_array;
        end
        for kkkk = 1:1:256
            Distance(1,kkkk) = sum(sum(abs(r - signal_csi(1:2,2*kkkk-1:2*kkkk))));
        end
        [minDis,Number] = min(Distance);
        so = array(Number,:);
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % �έp���~��bits��
        error_bits = sum(abs(si - so));
        % ���~�`bits��
        E = error_bits + E;
    end
    % ��X���~�v�íp����~�v�M�T�������Y
    Error(k) = E;
    Bits = sum(Error(:));
    BER_HR = [0.273062,0.253092,0.230231,0.206070,0.180984,0.156066,0.130380,0.105803,0.082596,0.062204,0.044746,0.031422,0.020452,0.012984,0.007939,0.004438,0.002473,0.001258,0.000659,0.000273,0.000150,0.000069,0.000025,0.000018,0.000009,0.000006];
    BER(k) = E/(N);
end
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
semilogy(SNRdB,BER_HR,'B-V',SNRdB,BER,'R-O');
grid on ;
legend('High Rate for Es','High Rate for Eb');
axis([0 25 10^-6 10^0]);
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('High Rate (TX=2,RX=2),CR=4');
xlabel('SNRdB');
ylabel('BER');
toc;