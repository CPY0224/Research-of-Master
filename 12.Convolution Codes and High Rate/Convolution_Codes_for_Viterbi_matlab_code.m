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
B = 64;
for k = 1:26
    error_bits = 0;
    E = 0;
    for x = 1:(1/B)*N
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % �}�l�s�X�A���ͰT��(�Q��BPSK����)
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
        % �}�l�� Convolution Code �� Trellis_Diagram�A��00�}�l
        trellis = poly2trellis(3,[7 5]);%(111,101) for 212
%         trellis = poly2trellis(4,[13 11]);%(1101,1011) for 213
%         trellis = poly2trellis(5,[31 27]);%(11111,11011) for 214
        codedData = convenc(transmitted_message,trellis);
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % �N�T����1�ܦ�1�A0�ܦ�-1
        transmitted_codeword_signal = 2*codedData - 1;
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % ����AWGN���T
        noise=TXNUM/(2*SNRb(k)); %�������T Es-Eb�� SNR ��o��!!
        % ����AWGN
        n = sqrt(noise)*randn(1,128);
        % �N���T�[�J�T��
        s = transmitted_codeword_signal + n;
        % �}�l�P�O�[�J���T�ᤧ�T��(Hard decoding)
        for xxx = 1:1:128
            if s(1,xxx) > 0
                received_word(1,xxx) = 1;
            elseif s(1,xxx) <= 0
                received_word(1,xxx) = 0;
            end
        end
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % �}�l��̤p�Z��
        tbdepth = 64;
        decoded_message = vitdec(received_word,trellis,tbdepth,'trunc','hard');
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % �έp���~��bits��
        error_bits = sum(abs(transmitted_message - decoded_message));
        % ���~�`bits��
        E = error_bits + E;
    end
    % ��X���~�v�íp����~�v�M�T�������Y
    Error(k) = E;
    Bits = sum(Error(:));
    BER(k) = E/(N);
end
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
semilogy(SNRdB,BER, 'B-V');
grid on ;
legend('(2,1,2)CC');
axis([0 25 10^-6 10^0]);
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for BER v.s SNR for Convolution_Codes for Viterbi');
xlabel('Eb/N0');
ylabel('BER');
toc;