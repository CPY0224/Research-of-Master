%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  [ Read Me First !! ]                                                                                                                %
%  --------------------                                                                                                                %
%  1. Variable:                                                                                                                        %
%     a. Change antenna of transmit : TXNUM                                                                                            %
%                                                                                                                                      %
%     b. If your number of antenna of recived is not equal 2, change size of array 'sys_ray' & 'sys_ray_array' and 'AWGN_array'.       %
%                                                                                                                                      %
%  2. User Note                                                                                                                        %
%     a. When this script be run, 'std_sig_256_QPSK.mat' and 'std_sig_256_RAW.mat' required !                                          %
%                                                                                                                                      %
%     b. If file 'std_sig_256_QPSK.mat' or 'std_sig_256_RAW.mat' is missing, section (title 'Generate Standard Signal (256 Signals)' ) %
%        must be run first !                                                                                                           %
%                                                                                                                                      %
%     c. If file 'std_sig_256_QPSK.mat' AND 'std_sig_256_RAW.mat' are existed, DO NOT run section                                      %
%        (title 'Generate Standard Signal (256 Signals)' ) !!                                                                          %
%                                                                                                                                      %
%     d. If you run this script without debug information, please mark when end of code with '% DEBUG ONLY !!!!'                       %
%                                                                                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
clc;
clear;
close all;
%delete Debug.csv; % DEBUG ONLY !!!!

% % ////////////////////////////////////////////////////////////////////////////////////////////////////////
% % Generate Standard Signal (256 Signals) (Just run once this section if "std_sig_256_QPSK.mat" & "std_sig_256_RAW.mat" is missing.) -- Start
% % ���ͼзǤ��T��(256���G)
% temp = zeros(255,8);                                                              % Pre-local memory (255 * 8)
% for kk = 1:1:255
%     xor(kk,1) = bitxor(0,kk);% �G�i����Q�i��[�k�A��0�}�l�[�A�C���[1�A�[���ᬰ�Q�i��
%     xor_char = dec2bin(xor);% �N�[���᪺�Q�i��Ʀr�A�ন�G�i��r��(char)
% end
% 
% for rol = 1:1:255
%     for col = 1:1:8
%         temp(rol,col) = xor_char(rol,col) - '0';% �ѩ�ASCII�s�X�����Y�A�ݭn�0�~��N�r��(char)�ন���(int)
%     end
% end
% array = [0,0,0,0,0,0,0,0;temp];                                                     % Add first signal "0 0 0 0 0 0 0 0".
% one = ones(256,8);                                                                  % Pre-local memory (256 * 8)
% array_signal = 2*array - one;                                                       % Generate binary signal (0 & 1).
% 
% for kkk = 1:1:256                                                                   % Generate QPSK Data -- Start
%     so1(kkk,:) = (1/sqrt(2)) * (array_signal(kkk,1) + array_signal(kkk,2)*1i);      % Generate QPSK Data - Dim. 1
%     so2(kkk,:) = (1/sqrt(2)) * (array_signal(kkk,3) + array_signal(kkk,4)*1i);      % Generate QPSK Data - Dim. 2
%     so3(kkk,:) = (1/sqrt(2)) * (array_signal(kkk,5) + array_signal(kkk,6)*1i);      % Generate QPSK Data - Dim. 3
%     so4(kkk,:) = (1/sqrt(2)) * (array_signal(kkk,7) + array_signal(kkk,8)*1i);      % Generate QPSK Data - Dim. 4
% end                                                                                 % Generate QPSK Data -- End
% 
% std_signal(1:256,1) = so1(:,:);                                                     % Copy QPSK Data to varaible "std_signal".
% std_signal(1:256,2) = so2(:,:);                                                     % Copy QPSK Data to varaible "std_signal".
% std_signal(1:256,3) = so3(:,:);                                                     % Copy QPSK Data to varaible "std_signal".
% std_signal(1:256,4) = so4(:,:);                                                     % Copy QPSK Data to varaible "std_signal".
% 
% save std_sig_256_QPSK.mat std_signal;                                               % Write QPSK Data to file "std_sig_256_QPSK.mat".
% save std_sig_256_RAW.mat array;                                                     % Write Raw Data to file "std_sig_256_RAW.mat".
% clear;
% clc;
% % Generate Standard Signal (256 Signals) (Just run once this section if "std_sig_256_QPSK.mat" & "std_sig_256_RAW.mat" is missing.) -- End
% % ////////////////////////////////////////////////////////////////////////////////////////////////////////////

load std_sig_256_QPSK.mat;                                                           % Load QPSK Data from file "std_sig_256_QPSK.mat".
load std_sig_256_RAW.mat;                                                            % Load QPSK Data from file "std_sig_256_RAW.mat".
% ����10^6��bits�A�H����1�M0
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
B = 8;
for k = 1:1:26
    if k <= 20
        N = 10^5;
    elseif  k > 20
        N = 10^6;
    end
    %N = 10000; % DEBUG ONLY !!!!
    disp(['Now is SNR ',num2str(k-1),' dB.']);
    error_bits = 0;                                                                 % Pre-local variable.
    error_bits_pre = 0;                                                             % Pre-local variable.
    for x = 1:(1/B)*N 
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        % �}�l�s�X�A���ͰT��
        s = randn(1,8);
        %s = [0 0 0 0 0 0 0 0]; % DEBUG ONLY !!!!
        %s = [1 1 1 1 1 1 1 1]; % DEBUG ONLY !!!!
        for xx = 1:1:8
            if s(1,xx) > 0
                si(1,xx) = 1;
            elseif s(1,xx) <= 0
                si(1,xx) = 0;
            end
            TX(1,xx) = 2*si(1,xx) - 1;
        end
        %dlmwrite('Debug.csv','Send','-append','delimiter',''); % DEBUG ONLY !!!!
        %dlmwrite('Debug.csv',si,'-append','delimiter',','); % DEBUG ONLY !!!!
        TX1 = [TX(1,1),TX(1,2)];
        TX2 = [TX(1,3),TX(1,4)];
        TX3 = [TX(1,5),TX(1,6)];
        TX4 = [TX(1,7),TX(1,8)];
        si1 = (1/sqrt(2)) * (TX(1,1) + TX(1,2)*1i); % QPSK Encode ( Dim 1)
        si2 = (1/sqrt(2)) * (TX(1,3) + TX(1,4)*1i); % QPSK Encode ( Dim 2)
        si3 = (1/sqrt(2)) * (TX(1,5) + TX(1,6)*1i); % QPSK Encode ( Dim 3)
        si4 = (1/sqrt(2)) * (TX(1,7) + TX(1,8)*1i); % QPSK Encode ( Dim 4)
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
        %sys_ray = [1+1i 1+1i 1+1i 1+1i]; % DEBUG ONLY !!!!
        % �N�p�Q�q�D�[�J�T��
        sys_ray_array = [sys_ray(1,1),sys_ray(1,2);sys_ray(1,3),sys_ray(1,4)];
        r_ray = high_rate_array * sys_ray_array;                                        % Cancel "dot"
        %/////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        %/////////////////////////////////////////////////////////////////////////////////////////////////////////
        % ����AWGN���T
        noise = TXNUM/(2*SNR(k)); %�������T Es-Eb�� SNR ��o��!!
        % ����AWGN
        n = sqrt(noise)*randn(1,8);
        % �N���T�[�J�w�]�t�p�Q�q�D���T��
        AWGN_array = [n(1,1) + n(1,2)*1i,n(1,3) + n(1,4)*1i;n(1,5) + n(1,6)*1i,n(1,7) + n(1,8)*1i];
        %AWGN_array = 0; % DEBUG ONLY !!!!
        r = r_ray + AWGN_array;
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        % �}�l�ѽX
        
        % Standard Signal (256 Signals) passed cahnnel. -- Start
        kkk = 0;
        for kkk = 1:1:256
            signal_one(kkk,1:2) = [std_signal(kkk,1)*sind(theta1)-(conj(std_signal(kkk,2)))*cosd(theta1),std_signal(kkk,3)*sind(theta2)-(conj(std_signal(kkk,4)))*cosd(theta2)];
            signal_two(kkk,1:2) = [-(conj(std_signal(kkk,3)))*sind(theta2)+std_signal(kkk,4)*cosd(theta2),conj(std_signal(kkk,1))*sind(theta1)-std_signal(kkk,2)*cosd(theta1)];
            
            signal(1:2,2*kkk-1:2*kkk) = [signal_one(kkk,1:2);signal_two(kkk,1:2)];
            signal_csi(1:2,2*kkk-1:2*kkk) = signal(1:2,2*kkk-1:2*kkk)*sys_ray_array;
        end
        % Standard Signal (256 Signals) passed cahnnel. -- End
        
        kkk = 0;
        for kkk = 1:1:256
            Distance(1,kkk) = sum(sum(abs(r - signal_csi(1:2,2*kkk-1:2*kkk))));
        end
        [minDis,Number] = min(Distance);
        so = array(Number,:);
        error_bits_pre = sum(abs(si - so));
        
        %dlmwrite('Debug.csv','Recv','-append','delimiter',''); % DEBUG ONLY !!!!
        %dlmwrite('Debug.csv',so,'-append','delimiter',','); % DEBUG ONLY !!!!
        % ////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        % �έp���~��bits��
        error_bits = error_bits + error_bits_pre ;
        %dlmwrite('Debug.csv',' ','-append','delimiter',''); % DEBUG ONLY !!!!
        %dlmwrite('Debug.csv','Err:','-append','delimiter',''); % DEBUG ONLY !!!!
        %dlmwrite('Debug.csv',error_bits,'-append','delimiter',''); % DEBUG ONLY !!!!
        % ���~�`bits��
    end
    Error(k) = error_bits;
    % ��X���~�v�íp����~�v�M�T�������Y
    BER(k) = error_bits/(N);
    
    dlmwrite('High-Rate_EsN0_snrdb.csv'   ,k              ,'-append','delimiter',',');
    dlmwrite('High-Rate_EsN0_snrdb.csv'   ,error_bits/(N) ,'-append','delimiter',',');
end
%semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure;
semilogy(SNRdB,BER, 'B-*');
grid on ;
legend('High Rate (Tx=2 ; Rx=2)');                                                      % Remark your number of antenna.
axis([0 25 10^-6 10^0]);
%�N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for BER v.s SNR for High Rate');
xlabel('Es/N0');
ylabel('BER');
saveas(gcf,'High-Rate.fig');                                                            % Save plot to *.fig.
saveas(gcf,'High-Rate.png');                                                            % Save plot to *.png.
toc;