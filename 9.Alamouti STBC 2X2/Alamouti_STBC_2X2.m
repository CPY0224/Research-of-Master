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
SNRb=2*(10.^((SNRdB)/10));%Eb
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
    sys_ray = sqrt(0.5)*(randn(1,4) + randn(1,4)*1i);
    % 將雷利通道加入訊號
    r_ray = [si1,si2;-(conj(si2)),conj(si1)]*[sys_ray(1,1),sys_ray(1,2);sys_ray(1,3),sys_ray(1,4)];
    for k = 1:26
        % 產生雜訊 Es-Eb的 SNR 改這裡!!
        noise=TXNUM/(2*SNRb(k));
        % 產生AWGN
        n = sqrt(noise)*randn(1,8);
        % 將雜訊加入已包含雷利通道的訊號
        AWGN_array = [n(1,1) + n(1,2)*1i,n(1,3) + n(1,4)*1i;n(1,5) + n(1,6)*1i,n(1,7) + n(1,8)*1i];
        r = r_ray + AWGN_array;
        % 開始做s1,s2訊號的編制
        temp = zeros(15,4);
        for kk = 1:1:15
            xor(kk,1) = bitxor(0,kk);% 二進位轉十進位加法，由0開始加，每次加1，加完後為十進位
            xor_char = dec2bin(xor);% 將加完後的十進位數字再轉成二進位字元(char)
        end
        for rol = 1:1:15
            for col = 1:1:4
                temp(rol,col) = xor_char(rol,col) - '0';% 由於ASCII編碼的關係，需要減掉0才能將字元(char)轉成整數(int)
            end
        end
        array = [0,0,0,0;temp];
        one = ones(16,4);
        array_signal = 2*array - one;
        for kkk = 1:1:16
            so1 = [(array_signal(kkk,1) + array_signal(kkk,2)*1i)];
            so2 = [(array_signal(kkk,3) + array_signal(kkk,4)*1i)];
            signal_one(kkk,1:2) = [so1,so2];
            signal_two(kkk,1:2) = [-(conj(so2)),conj(so1)];
            signal(1:2,2*kkk-1:2*kkk) = [signal_one(kkk,1:2);signal_two(kkk,1:2)];
            signal_csi(1:2,2*kkk-1:2*kkk) = signal(1:2,2*kkk-1:2*kkk)*[sys_ray(1,1),sys_ray(1,2);sys_ray(1,3),sys_ray(1,4)];
            Distance(1,kkk) = sum(sum(abs(signal_csi(1:2,2*kkk-1:2*kkk) - r)));
            [minDis,Number] = min(Distance);
        end
        for kkkk = 1:1:16
            if Number == kkkk
                so = array(kkkk,1:4);
            end
        end
        % 統計錯誤的bits數，算出錯誤率並計算錯誤率和訊雜比的關係
        error_bits = sum(abs(si - so));
        % 錯誤總bits數
        E = error_bits;
        Error(k) = E;
    end
    Bits = Bits + Error;
    BER = Bits/(N);
end
% semilogy函數可以使用y軸的對數刻度繪製數據
figure
semilogy(SNRdB,BER, 'B-V');
grid on ;
legend('Alamouti STBC 2X2');
axis([0 25 10^-6 10^0]);
% 將曲線圖之標題，X軸，Y軸各作標示
title('Alamouti STBC 2X2,CR=2');
xlabel('Eb/N0');
ylabel('BER');
toc;