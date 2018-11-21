function Rx_decoded_binary_symbols=OFDMReceiver(Rx_data,OP)
    %------------------------------------------------------------------------------------------------------
    %                                                                  接收端
    %------------------------------------------------------------------------------------------------------
    %----------------------------------串/并变换 去除前缀与后缀 OFDM解调---------------------------
    Rx_data_matrix=zeros(symbols_per_carrier+trainingSymbols_len+1,IFFT_bin_length+CP+CS);
    for i=1:symbols_per_carrier+trainingSymbols_len+1
        Rx_data_matrix(i,:)=Rx_data(1,(i-1)*(IFFT_bin_length+CP)+1:i*(IFFT_bin_length+CP)+CS);%串并变换
    end
    Rx_data_complex_matrix=Rx_data_matrix(:,CP+1:IFFT_bin_length+CP);%去除循环前缀与循环后缀，得到有用信号矩阵
    Y1=fft(Rx_data_complex_matrix,IFFT_bin_length,2);%FFT变换，OFDM解码
    %------------------------------------------频域均衡--------------------------------------------------
    Rx_carriers=Y1(:,carriers);%去除保护间隔与共轭数据
    RxTrainSymbols = Rx_carriers((1: trainingSymbols_len),: );%提取导频
    H = RxTrainSymbols./ trainingSymbols;%信道估计
    if (isnan(OP)) 
        OP=1;
    end
    if(OP)
        H_2 = abs(H).^2;
        H_2 = sum(H_2,1);%取均值减小误差
        H_C2 = sum(H,1);
        H_C2 = conj(H_C2);
        H = H_C2./H_2 ;    % 1/H = conj(H)/abs(H)^2
        Rx2 = ones(size(Rx_carriers,1),1)*H.*Rx_carriers;%Y=X*H, X=Y*1/H，单抽头均衡
    else
        Rx2 = Rx_carriers;
    end
    Rx = Rx2((trainingSymbols_len+1+1:size(Rx2,1)),:);%去除导频，提取调制信号
    Rx_phase =angle(Rx);%接收信号的相位
    Rx_mag = abs(Rx);%接收信号的幅度
    if (plot_config)
        figure('Name','RX Constellation Diagram I','NumberTitle','off');
        polarplot(Rx_phase, Rx_mag,'bd');%极坐标下接收信号的星座图
        title('RX信号的星座图（极坐标）')
        rlim([0, 10])
    end

    [M, N]=pol2cart(Rx_phase, Rx_mag); 
    Rx_complex_carrier_matrix = complex(M, N);

    if (plot_config)
        figure('Name','RX Constellation Diagram II','NumberTitle','off');
        plot(Rx_complex_carrier_matrix,'*b');%直角坐标下接收信号的星座图
        title('RX信号星座图（直角坐标）')
        axis square
        axis([-4, 4, -4, 4]);
        grid on
    end
    %------------------------------------------16QAM，QPSK解调--------------------------------------------------
    Rx_serial_complex_symbols=reshape(Rx_complex_carrier_matrix',size(Rx_complex_carrier_matrix, 1)*size(Rx_complex_carrier_matrix,2),1)' ;
    if (modulation==1)
        Rx_decoded_binary_symbols=demoduqam16(Rx_serial_complex_symbols);%16QAM
    else
        Rx_decoded_binary_symbols=demoduqpsk(Rx_serial_complex_symbols);%QPSK
    end
end



%-------------------------------------------比特流可视化-------------------------------------------------
