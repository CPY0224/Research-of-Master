tic;
clc;
clear;
close all;
% ����10^6��bits�A�H����1�M0
N=1000000;
% randn��Ʋ��ͱ`�A���G�����H����
% �]�wSNRdB�d��1~10,�C1���@�I
SNRdB=0:1:25;
% �ѽu�ƥ�
TXNUM=1;
% �������T Es,Eb �b�����(�n�|��)
SNR=10.^(SNRdB/10);%Eb
SNRb=1/2*(10.^((SNRdB)/10));%Es
% BER�z�׭�
BPSK = 1/2*erfc(sqrt(SNR));
Bits = zeros(1,length(SNR));
for x = 1:N
    % �s�X�AMo���s�X�᪺���G
    a = randn(1,1);
    b = randn(1,1);
    Si = a+b*1i;
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
    Mo = [Mo1,Mo2];
    amo = 2*Mo1-1;
    bmo = 2*Mo2-1;
    So = amo+bmo*1i;
    % Rayleigh fading channel
    sys_ray = sqrt(0.5)*( randn(1,1) + 1i*randn(1,1) );
    % �N�p�Q�q�D�[�J�T��
    ray_So = So*sys_ray;
    for k = 1:26
        % �������T Es-Eb�� SNR ��o��!!
        noise=TXNUM/(2*SNR(k));
        % ����AWGN
        n1 = sqrt(noise)*randn(1,1);
        n2 = sqrt(noise)*randn(1,1);
        % �N���T�[�J�w�]�t�p�Q�q�D���T��
        ray_So_AWGN = ray_So + (n1+n2*1i);
        % �w�[�J�p�Q�q�D����l�I
        ray_oo = (sqrt(2)*(+1+1i))*sys_ray; %11
        ray_zo = (sqrt(2)*(-1+1i))*sys_ray; %01
        ray_zz = (sqrt(2)*(-1-1i))*sys_ray; %00       
        ray_oz = (sqrt(2)*(+1-1i))*sys_ray; %10
        % �ѽX�ADemo���ѽX�᪺���G
        r_ray_oo = sum(abs(ray_So_AWGN - ray_oo)^2);
        r_ray_zo = sum(abs(ray_So_AWGN - ray_zo)^2);
        r_ray_zz = sum(abs(ray_So_AWGN - ray_zz)^2);
        r_ray_oz = sum(abs(ray_So_AWGN - ray_oz)^2);
        dis_ray_qpsk = [r_ray_oo,r_ray_zo,r_ray_zz,r_ray_oz];
        [mindis_qpsk,sequence] = min(dis_ray_qpsk);
        if sequence == 1
            minDemo = ray_oo;
        elseif sequence == 2
            minDemo = ray_zo;
        elseif sequence == 3
            minDemo = ray_zz;
        elseif sequence == 4
            minDemo = ray_oz;
        end
        if minDemo == ray_oo
            Demo = [1,1];
        elseif minDemo == ray_zo
            Demo = [0,1];
        elseif minDemo == ray_zz
            Demo = [0,0];
        elseif minDemo == ray_oz
            Demo = [1,0];
        end
        Demo1 = Demo(1,1);
        Demo2 = Demo(1,2);
        % �έp���~��bits�ơA��X���~�v�íp����~�v�M�T�������Y
        Re = sum(abs(Mo1(1,1) - Demo1(1,1)));
        Im = sum(abs(Mo2(1,1) - Demo2(1,1)));
        %���~�`bits��,�ðO���btotalE.
        E = Re + Im;
        Error(k) = E;
    end
    Bits = Bits + Error;
    BER = Bits/(N);
end
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
semilogy(SNRdB,BER, 'B-V');
grid on ;
legend('QPSK add Rayleigh');
axis([0 25 10^-6 10^0]);
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for BER v.s SNR for QPSK add fading channel');
xlabel('Eb/N0');
ylabel('BER');
toc;