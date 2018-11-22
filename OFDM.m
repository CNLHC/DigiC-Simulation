function BER=OFDM(using16QAM, SNR, L, plotEnable, SNR_test, CN, OP)
%输入参数：
%modulation:调制方式，1=16QAM，0=QPSK
%SNR：信噪比/dB
%L：信道多径数
%plot_config：绘图参数，1=绘制星座图
%输出：
%ber：误码率
%----------------------------------------------------
fprintf("OFDM-Session:\n\tSNR=%d\n\tPath:%d",SNR,L);
config = OFDMSettings(using16QAM, SNR, L, plotEnable, SNR_test, CN, OP);
%----------------------------------------------信号产生----------------------------------------------
[baseband_out,carriers]=OFDMSimpleSignalGenerator(config);

fprintf("%s:Transiver:Calculating\n",datestr(now,'HH:MM:SS.FFF'));
windowed_Tx_data=OFDMTransiver(baseband_out,carriers,config);
fprintf("%s:Channel:Calculating\n",datestr(now,'HH:MM:SS.FFF'));
Rx_data=OFDMChannel(windowed_Tx_data,config);
fprintf("%s:Receiver:Calculating\n",datestr(now,'HH:MM:SS.FFF'));
Rx_decoded_binary_symbols=OFDMReceiver(Rx_data,carriers,config);

baseband_in = Rx_decoded_binary_symbols;

if (plotEnable)
    figure('Name','Bit Stream','NumberTitle','off');
    subplot(2,1,1);
    stem(baseband_out(1:100));
    title('输出二进制比特流')
    subplot(2,1,2);
    stem(baseband_in(1:100));
    title('解调二进制比特流')
end

%-------------------------------------------误码率计算-------------------------------------------------
bit_errors=find(baseband_in ~= baseband_out);
Bit_Errors = size(bit_errors, 2);
BER=Bit_Errors/config('basebandOutLengthlength') ;
