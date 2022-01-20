% Viterbi
%  1:()                           2:()                          3:()
%  -------------------            -------------------           -------------------
%  | Message         |    -->     | Codeword        |    -->    | BPSK Signal     |
%  -------------------            -------------------     |     -------------------
%  (3 bit)                        (4 bit) Parity          |
%                                                         |     4:(AWGN_code)
%                                                         |     -------------------
%                                                        [+]<---| AWGN            |
%                                                         |     -------------------
%                                                         |
%  7:()                          6:()                     |     5:()
%  ------------------            -------------------      |     -------------------
%  | Decode Message |    <--     | Viterbi         |    <--     | Received Signal |
%  ------------------            -------------------            -------------------
%
%
% -- 2018.03.06 --
% ************************************************************************************
% *   Read Me                                                                        *
% ************************************************************************************
% *                                                                                  *
% * VARIABLE RULE                                                                    *
% * -------------                                                                    *
% * s_******  -> system variable.                                                    *
% * v_******  -> variable in Viterbi section.                                        *
% * v_tmp***  -> temporary variable in Viterbi section.                              *
% * v_val***  -> compare value variable in Viterbi section.                          *
% * v_ind***  -> compare index variable in Viterbi section.                          *
% * a ~ z     -> count variable.                                                     *
% * otherwise -> not belonging any class.                                            *
% *                                                                                  *
% * SECTION RULE                                                                     *
% * ------------                                                                     *
% * Layer 1:           ======== [ ****** Start       ] ========                      *
% *     Layer 2:       ==== ( ****** START               ) ====                      *
% *         Layer 3:   == ****** ==                                                  *
% *                                                                                  *
% ************************************************************************************
%======== [ INITIAL Start       ] ========
    tic;                                                                            % Clock start.
    clc;                                                                            % Clear All Commands.
    clear;                                                                          % Clear All Variables.
    close all;                                                                      % Close All plot Windows.
    delete Viterbi.mat;                                                             % Delete *.mat file.
%======== [ INITIAL End         ] ========                                          
                                                                                    
%======== [ MAIN FUNCTION Start ] ========                                          
    s_trans_bit = (10^6);                                                             
    % ==== ( SNR Configure         START) ====                                      
    snr_db = 0:1:11;                                                                % Configure range of snr_db from 0 to 10.
    snr    = 10.^(snr_db / 10);                                                     % Generate Noise( 10^(0/10) & 10^(1/10) & 10^(2/10) & ... 
                                                                                    % ... & 10^(8/10) & 10^(9/10) & 10^(10/10) ).
    ber_th = ( 1 / 2 )*erfc(sqrt(snr));                                             % BER Theoretical (Same as BPSK).
    % ==== ( SNR Configure         END) ====                                        
                                                                             
    for a = 1:length(snr_db)                                                        % Count of element in array(snr_db).
        s_error = 0;                                                                % Set variable(error) = 0
        for d = 1:floor((s_trans_bit))
    % ==== ( Generate Message Code START) ====
            x = linspace(0,1,1);                                                    % Configure range of x from 0 to 10.
            s_signal_1 = (sign(rand(1,1)-.5) + 1) / 2;                              % Generate original signal (0 or 1). (bit 1)
            s_signal_2 = (sign(rand(1,1)-.5) + 1) / 2;                              % Generate original signal (0 or 1). (bit 2)
            s_signal_3 = (sign(rand(1,1)-.5) + 1) / 2;                              % Generate original signal (0 or 1). (bit 3)
            s_parity_code = (s_signal_1 + s_signal_2 + s_signal_3);                 % Generate parity bit for signal.
            s_signal_4 = mod(s_parity_code,2);                                      % Generate parity bit.
            s_signal = [s_signal_1 ; s_signal_2 ; s_signal_3 ];                     % Generate original signal (1 symbol / 3 bit). (For check only.)
            s_signal_code = [s_signal_1 ; s_signal_2 ; s_signal_3 ; s_signal_4 ];   % Generate codeword of original signal (1 symbol / 4 bit).
            s_signal_bpsk = (s_signal_code * 2) - 1;                                % Converter signal to BPSK.
    % ==== ( Generate Message Code END  ) ====

    % ==== ( Mixed Message & AWGN START ) ====     
            s_noise = 1 / (2 * snr(a));                                             % Generate Noise
            s_awgn_code = sqrt( s_noise) * randn(4,1);                              % Generate AWGN signal (1 symbol / 4 bit).
            s_rcv_signal = s_signal_bpsk + s_awgn_code;                             % Receive signal = Original Signal + Noise(AWGN)            
    % ==== ( Mixed Message & AWGN END   ) ====
        
    % ==== ( Viterbi START              ) ====
        % ==== BMC (Start) ====
            % == DEBUG ==
            %s_rcv_signal(1,1) = -1.2;
            %s_rcv_signal(2,1) =  0.8;
            %s_rcv_signal(3,1) =  0.4;
            %s_rcv_signal(4,1) =  0.7;
            % == DEBUG ==
            
            % == Distance ==
            for v_dist = 1:4                                                        % bit : 4
                v_dist_1(v_dist,1) = ...                                            
                        (s_rcv_signal(v_dist,1) - (-1))^2;                          % Distance from bit 1 between "-1".

                v_dist_2(v_dist,1) = ...
                        (s_rcv_signal(v_dist,1) - ( 1))^2;                          % Distance from bit 1 between "+1".

                v_dist_path(1,1+0) = 0;                                             % Distance Matrix (bit 0 v.s -1). (Set 0 )
                v_dist_path(2,1+0) = 999;                                           % Distance Matrix (bit 0 v.s +1). (Set 999 )

                v_dist_path(1,1 + v_dist) = ...
                        v_dist_1(v_dist,1);                                         % Distance Matrix (bit 1 v.s -1).
                v_dist_path(2,1 + v_dist) = ...
                        v_dist_2(v_dist,1);                                         % Distance Matrix (bit 1 v.s +1).
            end
            % == Distance ==
        % ==== BMC (End) ====
            
        % ==== ACS (Start) ====
            
            % [ bit_table ]
            % -------------
            %
            %  m  | + 0  | + 1   (b1)  | + 2   (b2)  | + 3   (b3)  | + 4   (b4)   |
            %  --------------------------------------------------------------------------------
            %  1  | 0    | 0   + 0.04  | 0.04 + 3.24 | 3.28 + 1.96 | 0.44 + 2.89  |(-1)
            %  2  | 0    | 999 + 4.84  | 4.84 + 0.04 | 0.08 + 0.36 | 2.04 + 0.09  |(+1)
            %  --------------------------------------------------------------------------------
            %  3  | 999  | 0   + 4.84  | 0.04 + 0.04 | 3.28 + 0.36 |              |(-1)
            %  4  | 999  | 999 + 0.04  | 4.84 + 3.24 | 0.08 + 1.96 |              |(+1)
            %  --------------------------------------------------------------------------------
            %
            %      min(b0)      min(b1)       min(b2)       min(b3)        min(b4)
            %         0            0.04 *        3.28          0.44          3.33
            %                      4.84          0.08 *        2.04 *        2.13 *
            
            for v_bit_table_a = 1:2
                v_bit_table(1,1) = v_dist_path(1,1);
                v_bit_table(2,1) = v_dist_path(1,1);
                v_bit_table(3,1) = v_dist_path(2,1);
                v_bit_table(4,1) = v_dist_path(2,1);
                
                v_bit_table(1,1 + v_bit_table_a) = ...
                        v_bit_table(1,1) + v_dist_path(1 , 1 + v_bit_table_a);
                        
                v_bit_table(2,1 + v_bit_table_a) = ...
                        v_bit_table(3,1) + v_dist_path(2 , 1 + v_bit_table_a);
                        
                v_bit_table(3,1 + v_bit_table_a) = ...
                        v_bit_table(2,1) + v_dist_path(2 , 1 + v_bit_table_a);
                        
                v_bit_table(4,1 + v_bit_table_a) = ...
                        v_bit_table(4,1) + v_dist_path(1 , 1 + v_bit_table_a);
            end
            
            for v_bit_table_b = 2:4
                % n1 : -1(Negative) / p1 : +1(Positive)
                % u  : up           / d  : down
                [v_val_n1_u,v_ind_n1_u] = min([v_bit_table(1,1 + v_bit_table_b - 1),...
                        v_bit_table(2,1 + v_bit_table_b - 1)]);

                [v_val_p1_u,v_ind_p1_u] = min([v_bit_table(3,1 + v_bit_table_b - 1),...
                        v_bit_table(4,1 + v_bit_table_b - 1)]);

                [v_val_p1_d,v_ind_p1_d] = min([v_bit_table(2,1 + v_bit_table_b - 1),...
                        v_bit_table(1,1 + v_bit_table_b - 1)]);

                [v_val_n1_d,v_ind_n1_d] = min([v_bit_table(4,1 + v_bit_table_b - 1),...
                        v_bit_table(3,1 + v_bit_table_b - 1)]);

                v_bit_table(1,1 + v_bit_table_b) = v_val_n1_u + ...
                        v_dist_path(1 , 1 + v_bit_table_b);
                        
                v_bit_table(2,1 + v_bit_table_b) = v_val_p1_u + ...
                        v_dist_path(2 , 1 + v_bit_table_b);
                        
                v_bit_table(3,1 + v_bit_table_b) = v_val_p1_d + ...
                        v_dist_path(2 , 1 + v_bit_table_b);
                        
                v_bit_table(4,1 + v_bit_table_b) = v_val_n1_d + ...
                        v_dist_path(1 , 1 + v_bit_table_b);
            end
            
            for v_bit_table_c = 2:5
                v_tmp_a1 = v_bit_table(1,v_bit_table_c);
                v_tmp_a2 = v_bit_table(2,v_bit_table_c);
                v_tmp_a3 = v_bit_table(3,v_bit_table_c);
                v_tmp_a4 = v_bit_table(4,v_bit_table_c);
                
                [v_val_21,v_ind_21] = min([v_tmp_a1, v_tmp_a2]);
                [v_val_22,v_ind_22] = min([v_tmp_a3, v_tmp_a4]);
                
                v_acs_table(1,v_bit_table_c) = v_ind_21;
                v_acs_table(2,v_bit_table_c) = v_ind_22;
            end
            v_acs_table(1,1) = 0;
            v_acs_table(2,1) = 0;
        % ==== ACS (End) ====

        % ==== TBR (Start) ====
            v_Position = 1;
            v_tmp_L = 4;
            for b = 5:-1:2
                if v_Position == 1
                    if v_acs_table(1,b) == 1
                        v_rcv_signal(v_tmp_L,1) = 0;
                        v_Position = 1;
                    elseif v_acs_table(1,b) == 2
                        v_rcv_signal(v_tmp_L,1) = 1;
                        v_Position = 2;
                    end
                elseif v_Position == 2
                    if v_acs_table(2,b) == 1
                        v_rcv_signal(v_tmp_L,1) = 1;
                        v_Position = 1;
                    elseif v_acs_table(2,b) == 2
                        v_rcv_signal(v_tmp_L,1) = 0;
                        v_Position = 2;
                    end
                end
                v_tmp_L = v_tmp_L - 1;
            end 
            s_rcv_signal_viterbi = v_rcv_signal';
        % ==== TBR (End) ====
    % ==== ( Viterbi END                ) ====
        
    % ==== ( Compare Receive & Send     ) ====
            for c = 1:1                                                                 % Check received signal & original signal.
                if (s_rcv_signal_viterbi(c,1) == 1 && s_signal_code(1,1) == 0 || ...
                        s_rcv_signal_viterbi(c,1) == 0 && s_signal_code(1,1) == 1)
                    s_error = s_error + 1;
                end
                
                if (s_rcv_signal_viterbi(c,2) == 1 && s_signal_code(2,1) == 0 || ...
                        s_rcv_signal_viterbi(c,2) == 0 && s_signal_code(2,1) == 1)
                    s_error = s_error + 1;
                end
                
                if (s_rcv_signal_viterbi(c,3) == 1 && s_signal_code(3,1) == 0 || ...
                        s_rcv_signal_viterbi(c,3) == 0 && s_signal_code(3,1) == 1)
                    s_error = s_error + 1;
                end
                
                if (s_rcv_signal_viterbi(c,4) == 1 && s_signal_code(4,1) == 0 || ...
                        s_rcv_signal_viterbi(c,4) == 0 && s_signal_code(4,1) == 1)
                    s_error = s_error + 1;
                end
            end
    % ==== ( Compare Receive & Send     ) ====
        end
    s_error_rate = s_error / (3 * s_trans_bit);                                     % error rate = number of total error bits / number of total transmitted bits.
    ber_sim(a) = s_error_rate;
    end
%======== [ MAIN FUNCTION End   ] ========

%======== [ PLOT Start          ] ========
    figure;                                                                         % Open new plot windows.

    semilogy(snr_db,ber_th,'R-o');                                                  % Plot (SNR (Es/N0) v.s. BER Theoretical)
    hold on;                                                                        % Keep the last plot.
    semilogy(snr_db,ber_sim,'B-<');                                                 % Plot (SNR (Es/N0) v.s. BER Simulation)

    y_min = 7;                                                                      % Set minimum of y-axis.
    axis([min(snr_db) max(snr_db) 10.^(-y_min) 1]);                                 % Set range of y-axis.
    legend('BPSK (Theoretical)','Viterbi');                                         % Set legend.
    xlabel('Es/N0(dB)');                                                            % Set label of x-axis is "Es/N0(dB)".
    ylabel('BER');                                                                  % Set label of y-axis is "BER".
    title('Viterbi');                                                               % Set title is "Viterbi".
    grid on;                                                                        % Enable grid.
    hold off;
%======== [ PLOT End            ] ========

    pause (3);                                                                      % Delay 3 sec.
    save Viterbi.mat;                                                               % Save MAT file. (Variables of WorkSpace)
    clear x a b c d;                                                                % Clear variables. (For Debug)
    clear s_signal_1 s_signal_2 s_signal_3 s_signal_4;                              % Clear variables. (For Debug)
    clear s_parity_code s_signal_bpsk s_noise s_awgn_code s_rcv_signal;             % Clear variables. (For Debug)
    clear v_dist v_dist_1 v_dist_2 v_dist_path;                                     % Clear variables. (For Debug)
    clear v_bit_table_a v_bit_table_b v_bit_table_c;                                % Clear variables. (For Debug)
    clear v_val_n1_u v_ind_n1_u v_val_p1_d v_ind_p1_d;                              % Clear variables. (For Debug)
    clear v_val_n1_d v_ind_n1_d v_val_p1_u v_ind_p1_u;                              % Clear variables. (For Debug)
    clear v_tmp_a1 v_tmp_a2 v_tmp_a3 v_tmp_a4;                                      % Clear variables. (For Debug)
    clear v_val_21 v_ind_21 v_val_22 v_ind_22;                                      % Clear variables. (For Debug)
    clear v_Position v_tmp_L;                                                       % Clear variables. (For Debug)
    clear y_min;                                                                    % Clear variables. (For Debug)
    clear;                                                                          % Clear All Variables.
    toc;                                                                            % Clock stop.