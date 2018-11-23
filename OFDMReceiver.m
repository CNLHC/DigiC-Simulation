function Rx_demodulated_symbols=OFDMReceiver(Rx_data,carriers,config)
    IFFTLength=config('IFFTLength');
    SymbolsPerCarrier=config('SymbolsPerCarrier');
    CP=config('CPLength');
    CS=config('CSLength');
    OP=config('OP');
    plotEnable=config('plotEnable');
    using16QAM=config('using16QAM');
    trainingSymbols_len=config('TrainingSymbolsLength');
    trainingSymbols=config('trainingSymbols');

    %-------------------------------串/并变换 去除前缀与后缀 OFDM解调---------------------------
    Rx_data_matrix=zeros(SymbolsPerCarrier+trainingSymbols_len+1,IFFTLength+CP+CS);
    for i=1:SymbolsPerCarrier+trainingSymbols_len+1
        Rx_data_matrix(i,:)=Rx_data(1,(i-1)*(IFFTLength+CP)+1:i*(IFFTLength+CP)+CS);%串并变换
    end
    Rx_symbols=Rx_data_matrix(:,CP+1:IFFTLength+CP);%去除循环前缀与循环后缀，得到信号矩阵
    FFT_output=fft(Rx_symbols,IFFTLength,2);%FFT变换，OFDM解码
    %------------------------------------------频域均衡--------------------------------------------------
    Rx_carriers=FFT_output(:,carriers);%去除保护间隔与共轭数据
    RxTrainSymbols = Rx_carriers((1: trainingSymbols_len),: );%提取导频
    H = RxTrainSymbols./ trainingSymbols;%信道传递函数估计
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
    if (plotEnable)
        tFigureHandle=findobj(0,'Name','RX Constellation Diagram I');
        if(isempty(tFigureHandle))
            tFigureHandle=figure('Name','RX Constellation Diagram I','NumberTitle','off');
        else
           figure(tFigureHandle)
        end
        movegui(tFigureHandle,'northeast');
        polarplot(Rx_phase, Rx_mag,'bd');%极坐标下接收信号的星座图
        title('RX信号的星座图（极坐标）')
        rlim([0, 10])
    end

    [M, N]=pol2cart(Rx_phase, Rx_mag); 
    Rx_complex_carriers = complex(M, N);

    if (plotEnable)
        tFigureHandle=findobj(0,'Name','RX Constellation Diagram II');
        if(isempty(tFigureHandle))
            tFigureHandle= figure('Name','RX Constellation Diagram II','NumberTitle','off');
        else
           figure(tFigureHandle)
        end
        movegui(tFigureHandle,'southeast');
       
        plot(Rx_complex_carriers,'*b');%直角坐标下接收信号的星座图
        title('RX信号星座图（直角坐标）')
        axis square
        axis([-4, 4, -4, 4]);
        grid on
    end
    %------------------------------------------16QAM，QPSK解调--------------------------------------------------
    Rx_symbols=reshape(Rx_complex_carriers',size(Rx_complex_carriers, 1)*size(Rx_complex_carriers,2),1)' ;
    if (using16QAM==1)
        Rx_demodulated_symbols=QAM16_Demodulation(Rx_symbols);%16QAM
    else
        Rx_demodulated_symbols=QPSK_Demodulation(Rx_symbols);%QPSK
    end
end

