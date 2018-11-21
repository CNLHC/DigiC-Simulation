function Rx_data=OFDMChannel(windowed_Tx_data,config)
%------------------------------------------------Ƶ��ѡ���ŵ�------------------------------------------------------
    size_Tx=size(windowed_Tx_data,2);
    delay=1;%��L���ŵ�ʱ��Ϊ(L-1)/W����Ӧ����ƽ��һλ
    multipath_Tx_data=zeros(1,size_Tx);
    CN=config('CN');
    SNR=config('SNR');

    if(config('L')>=1&&(~config('SNR_test')))
        for i=1:config('L')
        temp=zeros(1,size_Tx);
        temp(delay*(i-1)+1:size_Tx)=windowed_Tx_data(1:size_Tx-delay*(i-1));
        multipath_Tx_data=multipath_Tx_data+temp*sqrt(1/(2*config('L')))*(randn(1)+1i*randn(1));%���Ӹ���ʱ���źţ��ŵ�����CN(0,1/L)
        end
    elseif (config('L')>=1&&config('SNR_test'))
        for i=1:config('L')
        temp=zeros(1,size_Tx);
        temp(delay*(i-1)+1:size_Tx)=windowed_Tx_data(1:size_Tx-delay*(i-1));
        multipath_Tx_data=multipath_Tx_data+temp*sqrt(1/(2*config('L')))*CN(i);%���Ӹ���ʱ���źţ��ŵ�����CN(0,1/L)
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
    noise=randn(1,((config('symbolsPerCarrier')+config('trainingSymbolsLength')+1)*(config('IFFTBinLength')+config('CPLength')))+config('CSLength'))*noise_scaling_factor;%����AWGN
    Rx_data=multipath_Tx_data+noise;%����AWGN
end