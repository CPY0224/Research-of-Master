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
SNRb=1/2*(10.^((SNRdB)/10));%Eb
% BER�z�׭�
BPSK = 1/2*erfc(sqrt(SNR));
Bits = zeros(1,length(SNR));
% �ݶ]�X��bits�A���H�X
B = 4;
for x = 1:(1/B)*N
    % �s�X�AMo���s�X�᪺���G
    s = randn(1,4);
    for xx = 1:1:4
        if s(1,xx) > 0
            si(1,xx) = 1;
        elseif s(1,xx) <= 0
            si(1,xx) = 0;
        end
        TX(1,xx) = 2*si(1,xx) - 1;
    end
    TX1 = [TX(1,1),TX(1,2)];
    TX2 = [TX(1,3),TX(1,4)];
    si1 = (1/sqrt(2))*(TX(1,1) + TX(1,2)*1i);
    si2 = (1/sqrt(2))*(TX(1,3) + TX(1,4)*1i);
    % Rayleigh fading channel
    sys_ray = sqrt(0.5)*(randn(1,2) + randn(1,2)*1i);
    % �N�p�Q�q�D�[�J�T��
    r_ray = [si1,si2;-(conj(si2)),conj(si1)]*[sys_ray(1,1);sys_ray(1,2)];
    for k = 1:26
        % �������T Es-Eb�� SNR ��o��!!
        noise=TXNUM/(2*SNR(k));
        % ����AWGN
        n = sqrt(noise)*randn(1,4);
        % �N���T�[�J�w�]�t�p�Q�q�D���T��
        AWGN_array = [n(1,1) + n(1,2)*1i;n(1,3) + n(1,4)*1i];
        r = r_ray + AWGN_array;
        % �}�l��s1,s2�T�����s��
        array = zeros(16,4);
        for kk = 1:1:4
            s1 = [0,0;0,1;1,0;1,1];
            s2 = [0,0;0,1;1,0;1,1];
            array(kk,1:4) = [s1(1,1:2),s2(kk,1:2)];
            array(kk+4,1:4) = [s1(2,1:2),s2(kk,1:2)];
            array(kk+8,1:4) = [s1(3,1:2),s2(kk,1:2)];
            array(kk+12,1:4) = [s1(4,1:2),s2(kk,1:2)];
        end
        one = ones(16,4);
        array_signal = 2*array - one;
        for kkk = 1:1:16
            signal_normal(kkk,1:2) = [array_signal(kkk,1) + array_signal(kkk,2)*1i,array_signal(kkk,3) + array_signal(kkk,4)*1i];
            signal_conj(kkk,1:2) = [-(conj(array_signal(kkk,3) + array_signal(kkk,4)*1i)),conj(array_signal(kkk,1) + array_signal(kkk,2)*1i)];
            signal(1:2,2*kkk-1:2*kkk) = [signal_normal(kkk,1:2);signal_conj(kkk,1:2)];
            signal_csi(1:2,kkk) = signal(1:2,2*kkk-1:2*kkk)*transpose(sys_ray);
            Distance(1,kkk) = sum(abs(signal_csi(1:2,kkk) - r));
            [minDis,Number] = min(Distance);
        end
        for kkkk = 1:1:16
            if Number == kkkk
                so = array(kkkk,1:4);
            end
        end
        % �έp���~��bits�ơA��X���~�v�íp����~�v�M�T�������Y
        Re1 = sum(abs(si(1,1) - so(1,1)));
        Re2 = sum(abs(si(1,3) - so(1,3)));
        Im1 = sum(abs(si(1,2) - so(1,2)));
        Im2 = sum(abs(si(1,4) - so(1,4)));
        % ���~�`bits��
        E = Re1 + Re2 + Im1 + Im2;
        Error(k) = E;
    end
    Bits = Bits + Error;
    BER = Bits/(N);
end
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
semilogy(SNRdB,BER, 'B-V');
grid on ;
legend('Alamouti STBC 2X1');
axis([0 25 10^-6 10^0]);
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for BER v.s SNR for Alamouti STBC 2X1');
xlabel('Es/N0');
ylabel('BER');
toc;