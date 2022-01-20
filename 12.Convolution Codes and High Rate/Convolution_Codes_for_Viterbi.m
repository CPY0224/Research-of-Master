tic;
clc;
clear;
close all;
% ����10^6��bits�A�H����1�M0
N=1000;
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
        u1 = transmitted_message(1,1);
        s0_s1_s2 = [0,0,0];
        temp = xor(u1,s0_s1_s2(1,1));
        temp2 = xor(u1,s0_s1_s2(1,2));
        v0 = xor(temp,s0_s1_s2(1,3));
        v1 = xor(temp2,s0_s1_s2(1,3));
        output = [v0,v1];
        v0_v1_1 = transpose(dec2bin(output) - '0');
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % �}�l�� Convolution Code �� Trellis_Diagram�A�ĤG����
        u1 = transmitted_message(1,2);
        s0_s1_s2 = [transmitted_message(1,1),s0_s1_s2(1,1),s0_s1_s2(1,2)];
        temp = xor(u1,s0_s1_s2(1,1));
        temp2 = xor(u1,s0_s1_s2(1,2));
        v0 = xor(temp,s0_s1_s2(1,3));
        v1 = xor(temp2,s0_s1_s2(1,3));
        output = [v0,v1];
        v0_v1_2 = transpose(dec2bin(output) - '0');
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % �}�l�� Convolution Code �� Trellis_Diagram
        for cc = 3:1:64
            u1 = transmitted_message(1,cc);
            s0_s1_s2 = [transmitted_message(1,cc-1),s0_s1_s2(1,1),s0_s1_s2(1,2)];
            temp = xor(u1,s0_s1_s2(1,1));
            temp2 = xor(u1,s0_s1_s2(1,2));
            v0 = xor(temp,s0_s1_s2(1,3));
            v1 = xor(temp2,s0_s1_s2(1,3));
            output(1,:) = [v0,v1];
            v0_v1_3(1,2*cc-5:2*cc-4) = transpose(dec2bin(output) - '0');
        end
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % �Nv0�Mv1�T����1�ܦ�1�A0�ܦ�-1
        transmitted_codeword = [v0_v1_1,v0_v1_2,v0_v1_3];
        transmitted_codeword_signal = 2*[v0_v1_1,v0_v1_2,v0_v1_3] - 1;
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % ����AWGN���T
        noise=TXNUM/(2*SNR(k)); %�������T Es-Eb�� SNR ��o��!!
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
        % �}�l�غc���|��
        road1 = [0,0;1,1];
        road2 = [1,0;0,1];
        road3 = [1,1;0,0];
        road4 = [0,1;1,0];
        road = [road1;road2;road3;road4];
        for xxxx = 1:1:2
            dis1(xxxx,:) = sum(abs(v0_v1_1 - road(xxxx,1:2)));
        end
        for xxxxx = 1:1:4
            dis2(xxxxx,:) = sum(abs(v0_v1_2 - road(xxxxx,1:2)));
        end
        for xxxxxx = 1:1:8
            for xxxxxxx = 1:1:62
                dis3(xxxxxx,xxxxxxx) = sum(abs(v0_v1_3(1,2*xxxxxxx-1:2*xxxxxxx) - road(xxxxxx,1:2)));
            end
        end
        dis = [[dis2;3;3;3;3],dis3];
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % �}�l��̤p�Z��
        minD0 = [dis1;3;3];
        D = zeros(8,63);
        D(1,1) = minD0(1,1) + dis(1,1);
        D(3,1) = minD0(1,1) + dis(2,1);
        D(5,1) = minD0(2,1) + dis(3,1);
        D(7,1) = minD0(2,1) + dis(4,1);
        D(2,1) = minD0(3,1) + dis(5,1);
        D(4,1) = minD0(3,1) + dis(6,1);
        D(6,1) = minD0(4,1) + dis(7,1);
        D(8,1) = minD0(4,1) + dis(8,1);
        minD1 = [min(D(1:2,1));min(D(3:4,1));min(D(5:6,1));min(D(7:8,1))];
        for d = 2:1:63
            for dd = 1:1:63
                D(1,d) = minD1(1,1) + dis(1,d);
                D(3,d) = minD1(1,1) + dis(2,d);
                D(5,d) = minD1(2,1) + dis(3,d);
                D(7,d) = minD1(2,1) + dis(4,d);
                D(2,d) = minD1(3,1) + dis(5,d);
                D(4,d) = minD1(3,1) + dis(6,d);
                D(6,d) = minD1(4,1) + dis(7,d);
                D(8,d) = minD1(4,1) + dis(8,d);
                minD1 = [min(D(1:2,d-1));min(D(3:4,d-1));min(D(5:6,d-1));min(D(7:8,d-1))];
                minD2(1:4,dd) = [min(D(1:2,dd));min(D(3:4,dd));min(D(5:6,dd));min(D(7:8,dd))];
            end
        end
        minD = [minD0,minD2];
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////
        % �}�l��̨θ��|
        decode_road = [road2;road4;road1;road3];
        for ddd = 64:-1:2
            [minD(:,ddd),number(1,ddd-1)] = min(D(8:-1:1,ddd-1));
        end
        % �}�l�P�O�T��
        decoded_message = zeros(1,64);
        if received_word(1,1:2) == [0,0]
            decoded_message(1,1) = 0;
        elseif received_word(1,1:2) == [1,1]
            decoded_message(1,1) = 1;
        end
        if received_word(1,3:4) == [0,0] | received_word(1,1:2) == [1,0]
            decoded_message(1,2) = 0;
        elseif received_word(1,3:4) == [1,1] | received_word(1,3:4) == [0,1]
            decoded_message(1,2) = 1;
        end
        for dddd = 3:1:64
            if number(1,dddd-1) == 2 || number(1,dddd-1) == 4 || number(1,dddd-1) == 6 || number(1,dddd-1) == 8
                if received_word(1,2*dddd-1:2*dddd) == [0,0] | received_word(1,2*dddd-1:2*dddd) == [1,0]
                    decoded_message(1,dddd) = 0;
                elseif received_word(1,2*dddd-1:2*dddd) == [1,1] | received_word(1,2*dddd-1:2*dddd) == [0,1]
                    decoded_message(1,dddd) = 1;
                end
            elseif number(1,dddd-1) == 1 || number(1,dddd-1) == 3 || number(1,dddd-1) == 5 || number(1,dddd-1) == 7
                if received_word(1,2*dddd-1:2*dddd) == [0,0] | received_word(1,2*dddd-1:2*dddd) == [1,0]
                    decoded_message(1,dddd) = 1;
                elseif received_word(1,2*dddd-1:2*dddd) == [1,1] | received_word(1,2*dddd-1:2*dddd) == [0,1]
                    decoded_message(1,dddd) = 0;
                end
            end
        end
        % /////////////////////////////////////////////////////////////////////////////////////////////////////////     
        
        % �έp���~��bits��
        error_bits = sum(abs(transmitted_message - decoded_message));
        % ���~�`bits��
        E = error_bits + E;
    end
    % ��X���~�v�íp����~�v�M�T�������Y
    Error(k) = E;
    Bits = sum(Error(:));
    BER = [0.170658000000000,0.141703000000000,0.113939000000000,0.0869840000000000,0.0626740000000000,0.0420400000000000,0.0256420000000000,0.0141100000000000,0.00662800000000000,0.00275600000000000,0.000863000000000000,0.000209000000000000,3.70000000000000e-05,2.00000000000000e-06,0,0,0,0,0,0,0,0,0,0,0,0];
    TheoryBER(k) = E/(N);
end
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
semilogy(SNRdB,BER, 'B-V',SNRdB,TheoryBER, 'R-O');
grid on ;
legend('(2,1,2) Convolution Codes for Viterbi','(2,1,3) Convolution Codes for Viterbi');
axis([0 25 10^-6 10^0]);
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for BER v.s SNR for Convolution_Codes for Viterbi');
xlabel('Es/N0');
ylabel('BER');
toc;