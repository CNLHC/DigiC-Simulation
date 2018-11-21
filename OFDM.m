function BER=OFDM(using16QAM, SNR, L, plotEnable, SNR_test, CN, OP)
%���������
%modulation:���Ʒ�ʽ��1=16QAM��0=QPSK
%SNR�������/dB
%L���ŵ��ྶ��
%plot_config����ͼ������1=��������ͼ
%�����
%ber��������
%----------------------------------------------------
config = OFDMSettings(using16QAM, SNR, L, plotEnable, SNR_test, CN, OP);
%----------------------------------------------�źŲ���----------------------------------------------
[baseband_out,conjugate_carriers]=OFDMSimpleSignalGenerator(config);

windowed_Tx_data=OFDMTransiver(baseband_out,conjugate_carriers,config);

Rx_data=OFDMChannel(windowed_Tx_data,config);

Rx_decoded_binary_symbols=OFDMReceiver(Rx_data,config);

baseband_in = Rx_decoded_binary_symbols;

if (plotEnable)
    figure('Name','Bit Stream','NumberTitle','off');
    subplot(2,1,1);
    stem(baseband_out(1:100));
    title('��������Ʊ�����')
    subplot(2,1,2);
    stem(baseband_in(1:100));
    title('��������Ʊ�����')
end

%-------------------------------------------�����ʼ���-------------------------------------------------
bit_errors=find(baseband_in ~= baseband_out);
Bit_Errors = size(bit_errors, 2);
BER=Bit_Errors/baseband_out_length;
