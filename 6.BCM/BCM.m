tic;
clc;
clear;
close all;
% ����10^6��bits�A�H����1�M0
N=1000000;
% randn��Ʋ��ͱ`�A���G�����H����
% �]�wSNRdB�d��1~10,�C1���@�I
SNRdB=0:1:10;
% �ѽu�ƥ�
TXNUM=1;
% �������T Es,Eb �b�����(�n�|��)
SNR=10.^(SNRdB/10);%Es
SNRb=15/16*(10.^((SNRdB)/10));%Eb
Bits = zeros(1,length(SNR));
for x = 1:N
    % �H�����;�ơA�d��0~1�A��16��
    Data = randi([0,1],1,16);
    %disp (['Data  : ' num2str(Data)]);
    eoe = Data(1,1:1); % ����1��@��818����¦
    %disp (['eoe   : ' num2str(eoe)]);
    est = Data(1,2:8); % ����2-8��@��872����¦
    %disp (['est   :    ' num2str(est)]);
    eeo = Data(1,9:16);% ����9-16��@��881����¦
    %disp (['eeo   :                         ' num2str(eeo)]);
    % �N��1�쭫�ƤK���ӥͦ�818code
    if eoe == 0
        eoe_code = repmat(eoe,1,8);
    elseif eoe == 1
        eoe_code = repmat(eoe,1,8);
    end
    %disp (['eoe_code  : ' num2str(eoe_code)]);
    p = mod(sum(est),2);% ��est�[�`�_�ӫᰣ2���l��
    est_code(1,1:7) = est;
    est_code(1,8) = p;
    %disp (['est_code  : ' num2str(est_code)]);
    eeo_code = eeo;
    %disp (['eeo_code  : ' num2str(eeo_code)]);
    block = [eoe_code;est_code;eeo_code];
    for m = 1:8
        if block(1:3,m) == [0;1;0]
            output(1,m) = 1i;
        elseif block(1:3,m) == [1;0;0]
            output(1,m) = sqrt(2)*(1+1i);
        elseif block(1:3,m) == [0;0;0]
            output(1,m) = 1;
        elseif block(1:3,m) == [1;1;1]
            output(1,m) = sqrt(2)*(1-1i);
        elseif block(1:3,m) == [0;1;1]
            output(1,m) = -1i;
        elseif block(1:3,m) == [1;0;1]
            output(1,m) = sqrt(2)*(-1-1i);
        elseif block(1:3,m) == [0;0;1]
            output(1,m) = -1;
        elseif block(1:3,m) == [1;1;0]
            output(1,m) = sqrt(2)*(-1+1i);
        end
    end
    for k = 1:11
        % �������T Es-Eb�� SNR ��o��!!
        noise=TXNUM/(2*SNR(k));
        % ����AWGN
        nRe = sqrt(noise)*randn(1,8);
        nIm = sqrt(noise)*randn(1,8);
        for S = 1:8
            % �N���T�[�J��T��
            y(1,S) = output(1,S) + (nRe(1,S) + nIm(1,S)*1i);
        end
        % �Ĥ@�h�ѽX
        for s = 1:8
            % �H0���}�Y���Z��
            zoz(1,s) = sum(abs(y(1,s) - (1i))^2);
            zzz(1,s) = sum(abs(y(1,s) - (1))^2);
            zoo(1,s) = sum(abs(y(1,s) - (-1i))^2);
            zzo(1,s) = sum(abs(y(1,s) - (-1))^2);
            z = [zoz;zzz;zoo;zzo];
            zmin(1,s) = min(z(1:4,s));
            % �H1���}�Y���Z��
            ozz(1,s) = sum(abs(y(1,s) - (sqrt(2)*(1+1i)))^2);
            ooo(1,s) = sum(abs(y(1,s) - (sqrt(2)*(1-1i)))^2);
            ozo(1,s) = sum(abs(y(1,s) - (sqrt(2)*(-1-1i)))^2);
            ooz(1,s) = sum(abs(y(1,s) - (sqrt(2)*(-1+1i)))^2);
            o = [ozz;ooo;ozo;ooz];
            omin(1,s) = min(o(1:4,s));
            if sum(zmin) < sum(omin)
                u1 = 0;
            elseif sum(zmin) > sum(omin)
                u1 = 1;
            end
            % �Ĥ@�h8��bits
            if u1 == 0
                first_code = [0,0,0,0,0,0,0,0];
            else
                first_code = [1,1,1,1,1,1,1,1];
            end
        end
        % �ĤG�h�ѽX
        zz = [zzz;zzo]; zo = [zoz;zoo];
        oz = [ozz;ozo]; oo = [ooz;ooo];
        for ss = 1:8
            zzmin(1,ss) = min(zz(1:2,ss));
            zomin(1,ss) = min(zo(1:2,ss));
            zeropk = [zzmin;zomin];
            ozmin(1,ss) = min(oz(1:2,ss));
            oomin(1,ss) = min(oo(1:2,ss));
            onepk = [ozmin;oomin];
            if u1 == 0
                v = zeropk;
            else
                v = onepk;
            end
        end
        % �C��bits�M0��1���Z��
        % �Ĥ@��Bit���j��
        au = 0 + v(1,1); ad = 0 + v(2,1);
        as = [au,ad]; minas = min(as);
        % �ĤG��Bit���j��
        buu = au + v(1,2); bud = ad + v(2,2);
        bdu = au + v(2,2); bdd = ad + v(1,2);
        bu = [buu,bud]; minbu = min(bu);
        bd = [bdu,bdd]; minbd = min(bd);
        % �ĤT��Bit���j��
        cuu = minbu + v(1,3); cud = minbd + v(2,3);
        cdu = minbu + v(2,3); cdd = minbd + v(1,3);
        cu = [cuu,cud]; mincu = min(cu);
        cd = [cdu,cdd]; mincd = min(cd);
        % �ĥ|��Bit���j��
        duu = mincu + v(1,4); dud = mincd + v(2,4);
        ddu = mincu + v(2,4); ddd = mincd + v(1,4);
        du = [duu,dud]; mindu = min(du);
        dd = [ddu,ddd]; mindd = min(dd);
        % �Ĥ���Bit���j��
        euu = mindu + v(1,5); eud = mindd + v(2,5);
        edu = mindu + v(2,5); edd = mindd + v(1,5);
        eu = [euu,eud]; mineu = min(eu);
        ed = [edu,edd]; mined = min(ed);
        % �Ĥ���Bit���j��
        fuu = mineu + v(1,6); fud = mined + v(2,6);
        fdu = mineu + v(2,6); fdd = mined + v(1,6);
        fu = [fuu,fud]; minfu = min(fu);
        fd = [fdu,fdd]; minfd = min(fd);
        % �ĤC��Bit���j��
        guu = minfu + v(1,7); gud = minfd + v(2,7);
        gdu = minfu + v(2,7); gdd = minfd + v(1,7);
        gu = [guu,gud]; mingu = min(gu);
        gd = [gdu,gdd]; mingd = min(gd);
        % �ĤK��Bit���j��
        hu = mingu + v(1,8); hd = mingd + v(2,8);
        hf = [hu,hd]; minhf = min(hf);
        % �N�Ҧ��Ȩ����@�}�C
        P = [au buu cuu duu euu fuu guu hu;
             au bud cud dud eud fud gud hu;
             ad bdu cdu cdu edu fdu gdu hd;
             ad bdd cdd ddd edd fdd gdd hd];
        % �N�̤p�Ȧs���@�Ӱ}�C
        PM = [0 minbu mincu mindu mineu minfu mingu minhf;
              1 minbd mincd mindd mined minfd mingd 100];
        % �}�l�P�O�o�ǭȸӨ�0�٬O1
        for p = 8:-1:1
            if PM(1,p) == P(1:1,p)
                bu(1,p) = 0;
            else
                bu(1,p) = 1;
            end
            if PM(2,p) == P(4:4,p)
                bd(1,p) = 0;
            else
                bd(1,p) = 1;
            end
            if minhf == hu
                bu(1,8) = 0;
            else
                bu(1,8) = 1;
            end
            bu(1,1) = 0;
            bd(1,1) = 1;
            bd(1,8) = 100;
            % �N�P�O�L�᪺0�άO1�A�s���@�}�C
            array = [bu;bd];
        end
            % �}�l��̨θ��|�A�Y�J��0�����J��1�ר�
            P = 0;% ������ơA0����1��A1���ĤG��
            X = 0;% �����P�_���S���]�L�A0���S�]�L�A1���]�L
            for pp = 8:-1:1
                if P == 0
                    if array(1,pp) == 0
                        second_code(1,pp) = 0;
                        P = 0;
                    elseif array(1,pp) == 1
                        second_code(1,pp) = 1;
                        P = 1;
                        X = 1;
                    end
                end
                if P == 1 && X == 0
                    if array(2,pp) == 0
                        second_code(1,pp) = 0;
                        P = 1;
                    elseif array(2,pp) == 1
                        second_code(1,pp) = 1;
                        P = 0;
                    end
                end
                X = 0;
            end
            VS = [bu;bd;second_code;est_code];
            % �ĤT�h�ѽX
            zz = [zzz;zzo]; zo = [zoz;zoo];
            oz = [ozz;ozo]; oo = [ooz;ooo];
            first_and_second = [first_code;second_code];
            for ppp = 1:1:8
                if first_and_second(1:2,ppp) == [0;0]
                    third(1:2,ppp) = zz(1:2,ppp);
                elseif first_and_second(1:2,ppp) == [0;1]
                    third(1:2,ppp) = zo(1:2,ppp);
                end
                if first_and_second(1:2,ppp) == [1;0]
                    third(1:2,ppp) = oz(1:2,ppp);
                elseif first_and_second(1:2,ppp) == [1;1]
                    third(1:2,ppp) = oo(1:2,ppp);
                end
                minthird(1,ppp) = min(third(1:2,ppp));
                if minthird(1,ppp) == third(1:1,ppp)
                    third_code(1,ppp) = 0;
                elseif minthird(1,ppp) == third(2:2,ppp)
                    third_code(1,ppp) = 1;
                end
            end
            BCM_code = [first_code;second_code;third_code];
            BCM_DATA = [u1,second_code(1,1:7),third_code];
            % �έp���~��bits�ơA��X���~�v�íp����~�v�M�T�������Y
            Re = sum(abs(Data(1,16) - BCM_DATA(1,16)));
            E = Re;
            Error(k) = E;
    end
    % ���~�`bits��,�ðO���btotalE.
    Bits = Bits + Error;
    BER = Bits/N;
end
% semilogy��ƥi�H�ϥ�y�b����ƨ��ø�s�ƾ�
figure
semilogy(SNRdB,BER,'B-V');
grid on ;
legend('BCM');
% �N���u�Ϥ����D�AX�b�AY�b�U�@�Х�
title('Curve for BCM');
xlabel('Es/N0');
ylabel('BER');
toc;