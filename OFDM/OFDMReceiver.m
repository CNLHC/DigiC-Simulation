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

    %-------------------------------��/���任 ȥ��ǰ׺���׺ OFDM���---------------------------
    Rx_data_matrix=zeros(SymbolsPerCarrier+trainingSymbols_len+1,IFFTLength+CP+CS);
    for i=1:SymbolsPerCarrier+trainingSymbols_len+1
        Rx_data_matrix(i,:)=Rx_data(1,(i-1)*(IFFTLength+CP)+1:i*(IFFTLength+CP)+CS);%�����任
    end
    Rx_symbols=Rx_data_matrix(:,CP+1:IFFTLength+CP);%ȥ��ѭ��ǰ׺��ѭ����׺���õ��źž���
    FFT_output=fft(Rx_symbols,IFFTLength,2);%FFT�任��OFDM����
    %------------------------------------------Ƶ�����--------------------------------------------------
    Rx_carriers=FFT_output(:,carriers);%ȥ����������빲������
    RxTrainSymbols = Rx_carriers((1: trainingSymbols_len),: );%��ȡ��Ƶ
    H = RxTrainSymbols./ trainingSymbols;%�ŵ����ݺ�������
    if (isnan(OP)) 
        OP=1;
    end
    if(OP)
        H_2 = abs(H).^2;
        H_2 = sum(H_2,1);%ȡ��ֵ��С���
        H_C2 = sum(H,1);
        H_C2 = conj(H_C2);
        H = H_C2./H_2 ;    % 1/H = conj(H)/abs(H)^2
        Rx2 = ones(size(Rx_carriers,1),1)*H.*Rx_carriers;%Y=X*H, X=Y*1/H������ͷ����
    else
        Rx2 = Rx_carriers;
    end
    Rx = Rx2((trainingSymbols_len+1+1:size(Rx2,1)),:);%ȥ����Ƶ����ȡ�����ź�
    Rx_phase =angle(Rx);%�����źŵ���λ
    Rx_mag = abs(Rx);%�����źŵķ���
    if (plotEnable)
        tFigureHandle=findobj(0,'Name','RX Constellation Diagram I');
        if(isempty(tFigureHandle))
            tFigureHandle=figure('Name','RX Constellation Diagram I','NumberTitle','off');
        else
           figure(tFigureHandle)
        end
        movegui(tFigureHandle,'northeast');
        polarplot(Rx_phase, Rx_mag,'bd');%�������½����źŵ�����ͼ
        title('RX�źŵ�����ͼ�������꣩')
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
       
        plot(Rx_complex_carriers,'*b');%ֱ�������½����źŵ�����ͼ
        title('RX�ź�����ͼ��ֱ�����꣩')
        axis square
        axis([-4, 4, -4, 4]);
        grid on
    end
    %------------------------------------------16QAM��QPSK���--------------------------------------------------
    Rx_symbols=reshape(Rx_complex_carriers',size(Rx_complex_carriers, 1)*size(Rx_complex_carriers,2),1)' ;
    if (using16QAM==1)
        Rx_demodulated_symbols=QAM16_Demodulation(Rx_symbols);%16QAM
    else
        Rx_demodulated_symbols=QPSK_Demodulation(Rx_symbols);%QPSK
    end
end

