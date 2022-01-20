tic;
clc;
clear;
close all;
% 產生10^6個bits，隨機的1和0
N=1000000;
% randn函數產生常態分佈的偽隨機數
% 設定SNRdB範圍0~25,每1取一點
SNRdB=0:1:25;
% 天線數目
TXNUM=2;
% 產生雜訊 Es,Eb 在此比較(要會算)
SNR=10.^(SNRdB/10);%Es
SNRb=1/2*(10.^((SNRdB)/10));%Eb
% BER理論值
BPSK = 1/2*erfc(sqrt(SNR));
Bits = zeros(1,length(SNR));
% 看跑幾個bits，除以幾
B = 4;
for x = 1:(1/B)*N
    % 編碼，Mo為編碼後的結果
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
    % 將雷利通道加入訊號
    r_ray = [si1,si2;-(conj(si2)),conj(si1)]*[sys_ray(1,1);sys_ray(1,2)];
    for k = 1:26
        % 產生雜訊 Es-Eb的 SNR 改這裡!!
        noise=TXNUM/(2*SNR(k));
        % 產生AWGN
        n = sqrt(noise)*randn(1,4);
        % 將雜訊加入已包含雷利通道的訊號
        AWGN_array = [n(1,1) + n(1,2)*1i;n(1,3) + n(1,4)*1i];
        r = r_ray + AWGN_array;
        % 開始做s1,s2訊號的編制
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
        % 統計錯誤的bits數，算出錯誤率並計算錯誤率和訊雜比的關係
        Re1 = sum(abs(si(1,1) - so(1,1)));
        Re2 = sum(abs(si(1,3) - so(1,3)));
        Im1 = sum(abs(si(1,2) - so(1,2)));
        Im2 = sum(abs(si(1,4) - so(1,4)));
        % 錯誤總bits數
        E = Re1 + Re2 + Im1 + Im2;
        Error(k) = E;
    end
    Bits = Bits + Error;
    BER = Bits/(N);
end
% semilogy函數可以使用y軸的對數刻度繪製數據
figure
semilogy(SNRdB,BER, 'B-V');
grid on ;
legend('Alamouti STBC 2X1');
axis([0 25 10^-6 10^0]);
% 將曲線圖之標題，X軸，Y軸各作標示
title('Curve for BER v.s SNR for Alamouti STBC 2X1');
xlabel('Es/N0');
ylabel('BER');
toc;
