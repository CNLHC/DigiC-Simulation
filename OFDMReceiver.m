function Rx_decoded_binary_symbols=OFDMReceiver(Rx_data,OP)
    %------------------------------------------------------------------------------------------------------
    %                                                                  ���ն�
    %------------------------------------------------------------------------------------------------------
    %----------------------------------��/���任 ȥ��ǰ׺���׺ OFDM���---------------------------
    Rx_data_matrix=zeros(symbols_per_carrier+trainingSymbols_len+1,IFFT_bin_length+CP+CS);
    for i=1:symbols_per_carrier+trainingSymbols_len+1
        Rx_data_matrix(i,:)=Rx_data(1,(i-1)*(IFFT_bin_length+CP)+1:i*(IFFT_bin_length+CP)+CS);%�����任
    end
    Rx_data_complex_matrix=Rx_data_matrix(:,CP+1:IFFT_bin_length+CP);%ȥ��ѭ��ǰ׺��ѭ����׺���õ������źž���
    Y1=fft(Rx_data_complex_matrix,IFFT_bin_length,2);%FFT�任��OFDM����
    %------------------------------------------Ƶ�����--------------------------------------------------
    Rx_carriers=Y1(:,carriers);%ȥ����������빲������
    RxTrainSymbols = Rx_carriers((1: trainingSymbols_len),: );%��ȡ��Ƶ
    H = RxTrainSymbols./ trainingSymbols;%�ŵ�����
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
    if (plot_config)
        figure('Name','RX Constellation Diagram I','NumberTitle','off');
        polarplot(Rx_phase, Rx_mag,'bd');%�������½����źŵ�����ͼ
        title('RX�źŵ�����ͼ�������꣩')
        rlim([0, 10])
    end

    [M, N]=pol2cart(Rx_phase, Rx_mag); 
    Rx_complex_carrier_matrix = complex(M, N);

    if (plot_config)
        figure('Name','RX Constellation Diagram II','NumberTitle','off');
        plot(Rx_complex_carrier_matrix,'*b');%ֱ�������½����źŵ�����ͼ
        title('RX�ź�����ͼ��ֱ�����꣩')
        axis square
        axis([-4, 4, -4, 4]);
        grid on
    end
    %------------------------------------------16QAM��QPSK���--------------------------------------------------
    Rx_serial_complex_symbols=reshape(Rx_complex_carrier_matrix',size(Rx_complex_carrier_matrix, 1)*size(Rx_complex_carrier_matrix,2),1)' ;
    if (modulation==1)
        Rx_decoded_binary_symbols=demoduqam16(Rx_serial_complex_symbols);%16QAM
    else
        Rx_decoded_binary_symbols=demoduqpsk(Rx_serial_complex_symbols);%QPSK
    end
end



%-------------------------------------------���������ӻ�-------------------------------------------------
