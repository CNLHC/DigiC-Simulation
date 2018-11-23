function Rx_data=OFDMChannel(windowed_Tx_data,config)
%------------------------------------------------频率选择信道------------------------------------------------------
    size_Tx=size(windowed_Tx_data,2);
    delay=1;%第L条信道时延为(L-1)/W，对应序列平移一位
    multipath_Tx_data=zeros(1,size_Tx);
    CN=config('CN');
    SNR=config('SNR');

    if(config('L')>=1&&(~config('SNR_test')))
        for i=1:config('L')
        temp=zeros(1,size_Tx);
        temp(delay*(i-1)+1:size_Tx)=windowed_Tx_data(1:size_Tx-delay*(i-1));
        multipath_Tx_data=multipath_Tx_data+temp*sqrt(1/(2*config('L')))*(randn(1)+1i*randn(1));%叠加各个时延信号，信道符合CN(0,1/L)
        end
    elseif (config('L')>=1&&config('SNR_test'))
        for i=1:config('L')
        temp=zeros(1,size_Tx);
        temp(delay*(i-1)+1:size_Tx)=windowed_Tx_data(1:size_Tx-delay*(i-1));
        multipath_Tx_data=multipath_Tx_data+temp*sqrt(1/(2*config('L')))*CN(i);%叠加各个时延信号，信道符合CN(0,1/L)
        end
    else
        multipath_Tx_data=windowed_Tx_data;%AWGN信道
    end
    Tx_signal_power = var(multipath_Tx_data);%接收信号功率
    if (isnan(SNR)) 
        SNR=20;
    end
    linear_SNR=10^(SNR/10);%线性信噪比 
    noise_sigma=Tx_signal_power/linear_SNR;%噪声sigma
    noise_scaling_factor = sqrt(noise_sigma);%标准差
    noise=randn(1,((config('symbolsPerCarrier')+config('trainingSymbolsLength')+1)*(config('IFFTBinLength')+config('CPLength')))+config('CSLength'))*noise_scaling_factor;%产生AWGN
    Rx_data=multipath_Tx_data+noise;%叠加AWGN
end