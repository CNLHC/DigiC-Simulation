function Rx_data=OFDMChannel(windowed_Tx_data,SNR,SNR_test)
%------------------------------------------------Ƶ��ѡ���ŵ�------------------------------------------------------
    size_Tx=size(windowed_Tx_data,2);
    delay=1;%��L���ŵ�ʱ��Ϊ(L-1)/W����Ӧ����ƽ��һλ
    multipath_Tx_data=zeros(1,size_Tx);

    if(L>=1&&(~SNR_test))
        for i=1:L
        temp=zeros(1,size_Tx);
        temp(delay*(i-1)+1:size_Tx)=windowed_Tx_data(1:size_Tx-delay*(i-1));
        multipath_Tx_data=multipath_Tx_data+temp*sqrt(1/(2*L))*(randn(1)+1i*randn(1));%���Ӹ���ʱ���źţ��ŵ�����CN(0,1/L)
        end
    elseif (L>=1&&SNR_test)
        for i=1:L
        temp=zeros(1,size_Tx);
        temp(delay*(i-1)+1:size_Tx)=windowed_Tx_data(1:size_Tx-delay*(i-1));
        multipath_Tx_data=multipath_Tx_data+temp*sqrt(1/(2*L))*CN(i);%���Ӹ���ʱ���źţ��ŵ�����CN(0,1/L)
        end
    else
        multipath_Tx_data=windowed_Tx_data;%AWGN�ŵ�
    end
    Tx_signal_power = var(multipath_Tx_data);%�����źŹ���
    if (isnan(SNR)) 
        SNR=20;
    end
    linear_SNR=10^(SNR/10);%��������� 
    noise_sigma=Tx_signal_power/linear_SNR;%����sigma
    noise_scaling_factor = sqrt(noise_sigma);%��׼��
    noise=randn(1,((symbols_per_carrier+trainingSymbols_len+1)*(IFFT_bin_length+CP))+CS)*noise_scaling_factor;%����AWGN
    Rx_data=multipath_Tx_data+noise;%����AWGN
end