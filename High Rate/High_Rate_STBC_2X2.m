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
SNRb=4*(10.^((SNRdB)/10));%Eb
% BER理論值
BPSK = 1/2*erfc(sqrt(SNR));
Bits = zeros(1,length(SNR));
% 看跑幾個bits，除以幾
B = 8;
% ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
% 產生標準比對訊號(256結果)
temp = zeros(255,8);
for kk = 1:1:255
    xor(kk,1) = bitxor(0,kk);% 二進位轉十進位加法，由0開始加，每次加1，加完後為十進位
    xor_char = dec2bin(xor);% 將加完後的十進位數字再轉成二進位字元(char)
end
for rol = 1:1:255
    for col = 1:1:8
        temp(rol,col) = xor_char(rol,col) - '0';% 由於ASCII編碼的關係，需要減掉0才能將字元(char)轉成整數(int)
    end
end
% ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

% ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
% 標準比對訊號(256結果)
array = [0,0,0,0,0,0,0,0;temp];
% ////////////////////////////////////////////////////////////////////////////////////////////////////////////////

% 開始High Rate STBC 2X2編制
for k = 1:26
    error_bits = 0;
    E = 0;
    for x = 1:(1/B)*N 
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        % 開始編碼，產生訊號
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
        % 產生High Rate訊號
        theta1 = 63.4;
        theta2 = 90-theta1;
        high_rate_array = [si1*sind(theta1)-(conj(si2))*cosd(theta1),si3*sind(theta2)-(conj(si4))*cosd(theta2)
                          -(conj(si3))*sind(theta2)+si4*cosd(theta2),(conj(si1))*sind(theta1)-si2*cosd(theta1)];
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////                             

        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        % 產生通道雜訊:Rayleigh fading channel
        sys_ray = sqrt(0.5)*(randn(1,4) + randn(1,4)*1i);
        % 將雷利通道加入訊號
        sys_ray_array = [sys_ray(1,1),sys_ray(1,2);sys_ray(1,3),sys_ray(1,4)];
        r_ray = high_rate_array*sys_ray_array;
        %/////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        %/////////////////////////////////////////////////////////////////////////////////////////////////////////
        % 產生AWGN雜訊
        noise=TXNUM/(2*SNRb(k)); %產生雜訊 Es-Eb的 SNR 改這裡!!
        % 產生AWGN
        n = sqrt(noise)*randn(1,8);
        % 將雜訊加入已包含雷利通道的訊號
        AWGN_array = [n(1,1) + n(1,2)*1i,n(1,3) + n(1,4)*1i;n(1,5) + n(1,6)*1i,n(1,7) + n(1,8)*1i];
        r = r_ray + AWGN_array;
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        % 開始解碼
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
        
        % 統計錯誤的bits數
        error_bits = sum(abs(si - so));
        % 錯誤總bits數
        E = error_bits + E;
    end
    % 算出錯誤率並計算錯誤率和訊雜比的關係
    Error(k) = E;
    Bits = sum(Error(:));
    BER_HR = [0.273062,0.253092,0.230231,0.206070,0.180984,0.156066,0.130380,0.105803,0.082596,0.062204,0.044746,0.031422,0.020452,0.012984,0.007939,0.004438,0.002473,0.001258,0.000659,0.000273,0.000150,0.000069,0.000025,0.000018,0.000009,0.000006];
    BER(k) = E/(N);
end
% semilogy函數可以使用y軸的對數刻度繪製數據
figure
semilogy(SNRdB,BER_HR,'B-V',SNRdB,BER,'R-O');
grid on ;
legend('High Rate for Es','High Rate for Eb');
axis([0 25 10^-6 10^0]);
% 將曲線圖之標題，X軸，Y軸各作標示
title('High Rate (TX=2,RX=2),CR=4');
xlabel('SNRdB');
ylabel('BER');
toc;
