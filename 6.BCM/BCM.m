tic;
clc;
clear;
close all;
% 產生10^6個bits，隨機的1和0
N=1000000;
% randn函數產生常態分佈的偽隨機數
% 設定SNRdB範圍1~10,每1取一點
SNRdB=0:1:10;
% 天線數目
TXNUM=1;
% 產生雜訊 Es,Eb 在此比較(要會算)
SNR=10.^(SNRdB/10);%Es
SNRb=15/16*(10.^((SNRdB)/10));%Eb
Bits = zeros(1,length(SNR));
for x = 1:N
    % 隨機產生整數，範圍0~1，取16位
    Data = randi([0,1],1,16);
    %disp (['Data  : ' num2str(Data)]);
    eoe = Data(1,1:1); % 取第1位作為818的基礎
    %disp (['eoe   : ' num2str(eoe)]);
    est = Data(1,2:8); % 取第2-8位作為872的基礎
    %disp (['est   :    ' num2str(est)]);
    eeo = Data(1,9:16);% 取第9-16位作為881的基礎
    %disp (['eeo   :                         ' num2str(eeo)]);
    % 將第1位重複八次來生成818code
    if eoe == 0
        eoe_code = repmat(eoe,1,8);
    elseif eoe == 1
        eoe_code = repmat(eoe,1,8);
    end
    %disp (['eoe_code  : ' num2str(eoe_code)]);
    p = mod(sum(est),2);% 把est加總起來後除2取餘數
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
        % 產生雜訊 Es-Eb的 SNR 改這裡!!
        noise=TXNUM/(2*SNR(k));
        % 產生AWGN
        nRe = sqrt(noise)*randn(1,8);
        nIm = sqrt(noise)*randn(1,8);
        for S = 1:8
            % 將雜訊加入原訊號
            y(1,S) = output(1,S) + (nRe(1,S) + nIm(1,S)*1i);
        end
        % 第一層解碼
        for s = 1:8
            % 以0為開頭的距離
            zoz(1,s) = sum(abs(y(1,s) - (1i))^2);
            zzz(1,s) = sum(abs(y(1,s) - (1))^2);
            zoo(1,s) = sum(abs(y(1,s) - (-1i))^2);
            zzo(1,s) = sum(abs(y(1,s) - (-1))^2);
            z = [zoz;zzz;zoo;zzo];
            zmin(1,s) = min(z(1:4,s));
            % 以1為開頭的距離
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
            % 第一層8個bits
            if u1 == 0
                first_code = [0,0,0,0,0,0,0,0];
            else
                first_code = [1,1,1,1,1,1,1,1];
            end
        end
        % 第二層解碼
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
        % 每個bits和0及1的距離
        % 第一個Bit的迴圈
        au = 0 + v(1,1); ad = 0 + v(2,1);
        as = [au,ad]; minas = min(as);
        % 第二個Bit的迴圈
        buu = au + v(1,2); bud = ad + v(2,2);
        bdu = au + v(2,2); bdd = ad + v(1,2);
        bu = [buu,bud]; minbu = min(bu);
        bd = [bdu,bdd]; minbd = min(bd);
        % 第三個Bit的迴圈
        cuu = minbu + v(1,3); cud = minbd + v(2,3);
        cdu = minbu + v(2,3); cdd = minbd + v(1,3);
        cu = [cuu,cud]; mincu = min(cu);
        cd = [cdu,cdd]; mincd = min(cd);
        % 第四個Bit的迴圈
        duu = mincu + v(1,4); dud = mincd + v(2,4);
        ddu = mincu + v(2,4); ddd = mincd + v(1,4);
        du = [duu,dud]; mindu = min(du);
        dd = [ddu,ddd]; mindd = min(dd);
        % 第五個Bit的迴圈
        euu = mindu + v(1,5); eud = mindd + v(2,5);
        edu = mindu + v(2,5); edd = mindd + v(1,5);
        eu = [euu,eud]; mineu = min(eu);
        ed = [edu,edd]; mined = min(ed);
        % 第六個Bit的迴圈
        fuu = mineu + v(1,6); fud = mined + v(2,6);
        fdu = mineu + v(2,6); fdd = mined + v(1,6);
        fu = [fuu,fud]; minfu = min(fu);
        fd = [fdu,fdd]; minfd = min(fd);
        % 第七個Bit的迴圈
        guu = minfu + v(1,7); gud = minfd + v(2,7);
        gdu = minfu + v(2,7); gdd = minfd + v(1,7);
        gu = [guu,gud]; mingu = min(gu);
        gd = [gdu,gdd]; mingd = min(gd);
        % 第八個Bit的迴圈
        hu = mingu + v(1,8); hd = mingd + v(2,8);
        hf = [hu,hd]; minhf = min(hf);
        % 將所有值取成一陣列
        P = [au buu cuu duu euu fuu guu hu;
             au bud cud dud eud fud gud hu;
             ad bdu cdu cdu edu fdu gdu hd;
             ad bdd cdd ddd edd fdd gdd hd];
        % 將最小值存成一個陣列
        PM = [0 minbu mincu mindu mineu minfu mingu minhf;
              1 minbd mincd mindd mined minfd mingd 100];
        % 開始判別這些值該走0還是1
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
            % 將判別過後的0或是1再存成一陣列
            array = [bu;bd];
        end
            % 開始找最佳路徑，若遇到0直走遇到1斜走
            P = 0;% 此為行數，0為第1行，1為第二行
            X = 0;% 此為判斷有沒有跑過，0為沒跑過，1為跑過
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
            % 第三層解碼
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
            % 統計錯誤的bits數，算出錯誤率並計算錯誤率和訊雜比的關係
            Re = sum(abs(Data(1,16) - BCM_DATA(1,16)));
            E = Re;
            Error(k) = E;
    end
    % 錯誤總bits數,並記錄在totalE.
    Bits = Bits + Error;
    BER = Bits/N;
end
% semilogy函數可以使用y軸的對數刻度繪製數據
figure
semilogy(SNRdB,BER,'B-V');
grid on ;
legend('BCM');
% 將曲線圖之標題，X軸，Y軸各作標示
title('Curve for BCM');
xlabel('Es/N0');
ylabel('BER');
toc;