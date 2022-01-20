tic;
clc;
clear;
close all;
% 產生10^6個bits，隨機的1和0
N=1000000;
% randn函數產生常態分佈的偽隨機數
% 設定SNRdB範圍1~10,每1取一點
SNRdB=0:1:25;
% 天線數目
TXNUM=1;
% 產生雜訊 Es,Eb 在此比較(要會算)
SNR=10.^(SNRdB/10);%Eb
SNRb=1/2*(10.^((SNRdB)/10));%Es
% BER理論值
BPSK = 1/2*erfc(sqrt(SNR));
Bits = zeros(1,length(SNR));
for x = 1:N
    % 編碼，Mo為編碼後的結果
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
    % 將雷利通道加入訊號
    ray_So = So*sys_ray;
    for k = 1:26
        % 產生雜訊 Es-Eb的 SNR 改這裡!!
        noise=TXNUM/(2*SNR(k));
        % 產生AWGN
        n1 = sqrt(noise)*randn(1,1);
        n2 = sqrt(noise)*randn(1,1);
        % 將雜訊加入已包含雷利通道的訊號
        ray_So_AWGN = ray_So + (n1+n2*1i);
        % 已加入雷利通道的原始點
        ray_oo = (sqrt(2)*(+1+1i))*sys_ray; %11
        ray_zo = (sqrt(2)*(-1+1i))*sys_ray; %01
        ray_zz = (sqrt(2)*(-1-1i))*sys_ray; %00       
        ray_oz = (sqrt(2)*(+1-1i))*sys_ray; %10
        % 解碼，Demo為解碼後的結果
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
        % 統計錯誤的bits數，算出錯誤率並計算錯誤率和訊雜比的關係
        Re = sum(abs(Mo1(1,1) - Demo1(1,1)));
        Im = sum(abs(Mo2(1,1) - Demo2(1,1)));
        %錯誤總bits數,並記錄在totalE.
        E = Re + Im;
        Error(k) = E;
    end
    Bits = Bits + Error;
    BER = Bits/(N);
end
% semilogy函數可以使用y軸的對數刻度繪製數據
figure
semilogy(SNRdB,BER, 'B-V');
grid on ;
legend('QPSK add Rayleigh');
axis([0 25 10^-6 10^0]);
% 將曲線圖之標題，X軸，Y軸各作標示
title('Curve for BER v.s SNR for QPSK add fading channel');
xlabel('Eb/N0');
ylabel('BER');
toc;
