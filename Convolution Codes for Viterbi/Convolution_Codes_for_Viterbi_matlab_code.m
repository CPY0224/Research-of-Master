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
B = 64;
for k = 1:26
    error_bits = 0;
    E = 0;
    for x = 1:(1/B)*N
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % 開始編碼，產生訊號(利用BPSK調變)
        Signal_encode = randn(1,64);
        for xx = 1:1:64
            if Signal_encode(1,xx) > 0
                transmitted_message(1,xx) = 1;
            elseif Signal_encode(1,xx) <= 0
                transmitted_message(1,xx) = 0;
            end
        end
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % 開始走 Convolution Code 的 Trellis_Diagram，由00開始
        trellis = poly2trellis(3,[7 5]);
        codedData = convenc(transmitted_message,trellis);
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % 將訊號由1變成1，0變成-1
        transmitted_codeword_signal = 2*codedData - 1;
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % 產生AWGN雜訊
        noise=TXNUM/(2*SNR(k)); %產生雜訊 Es-Eb的 SNR 改這裡!!
        % 產生AWGN
        n = sqrt(noise)*randn(1,128);
        % 將雜訊加入訊號
        s = transmitted_codeword_signal + n;
        % 開始判別加入雜訊後之訊號(Hard decoding)
        for xxx = 1:1:128
            if s(1,xxx) > 0
                received_word(1,xxx) = 1;
            elseif s(1,xxx) <= 0
                received_word(1,xxx) = 0;
            end
        end
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % 開始算最小距離
        tbdepth = 64;
        decoded_message = vitdec(received_word,trellis,tbdepth,'trunc','hard');
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % 統計錯誤的bits數
        error_bits = sum(abs(transmitted_message - decoded_message));
        % 錯誤總bits數
        E = error_bits + E;
    end
    % 算出錯誤率並計算錯誤率和訊雜比的關係
    Error(k) = E;
    Bits = sum(Error(:));
    BER = [0.170658000000000,0.141703000000000,0.113939000000000,0.0869840000000000,0.0626740000000000,0.0420400000000000,0.0256420000000000,0.0141100000000000,0.00662800000000000,0.00275600000000000,0.000863000000000000,0.000209000000000000,3.70000000000000e-05,2.00000000000000e-06,0,0,0,0,0,0,0,0,0,0,0,0];
    TheoryBER(k) = E/(N);
end
% semilogy函數可以使用y軸的對數刻度繪製數據
figure
semilogy(SNRdB,BER, 'B-V',SNRdB,TheoryBER, 'R-O');
grid on ;
legend('Myself Convolution Codes for Viterbi','Matlab Convolution Codes for Viterbi');
axis([0 25 10^-6 10^0]);
% 將曲線圖之標題，X軸，Y軸各作標示
title('Curve for BER v.s SNR for Convolution_Codes for Viterbi');
xlabel('Es/N0');
ylabel('BER');
toc;
