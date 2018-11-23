function BER=OFDM(config,baseband_out)
%----------------------------------------------------
fprintf("OFDM-Session:\n\tSNR=%d\n\tPath:%d",config('SNR'),config('L'));
%----------------------------------------------信号产生----------------------------------------------
% baseband_out=OFDMSimpleSignalGenerator(config);
carriers = (1:config('carrierCounts'))+(floor(config('IFFTBinLength')/4) -floor(config('carrierCounts')/2));%共轭对称子载波映射，原复数数据对应坐标
fprintf("%s:Transiver:Calculating\n",datestr(now,'HH:MM:SS.FFF'));
windowed_Tx_data=OFDMTransiver(baseband_out,carriers,config);
fprintf("%s:Channel:Calculating\n",datestr(now,'HH:MM:SS.FFF'));
Rx_data=OFDMChannel(windowed_Tx_data,config);
fprintf("%s:Receiver:Calculating\n",datestr(now,'HH:MM:SS.FFF'));
Rx_decoded_binary_symbols=OFDMReceiver(Rx_data,carriers,config);

baseband_in = Rx_decoded_binary_symbols;

if (config('plotEnable'))
    tFigureHandle=findobj(0,'Name','Bit Stream');
    if(isempty(tFigureHandle))
        tFigureHandle=  figure('Name','Bit Stream','NumberTitle','off');
    else
       figure(tFigureHandle)
    end
    movegui(tFigureHandle,'southwest');
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
