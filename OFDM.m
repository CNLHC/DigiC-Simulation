function BER=OFDM(config,Baseband)

fprintf("OFDM-Session:\n\tSNR=%g\n\tPath:%d\n",config('SNR'),config('L'));
carriers = (1:config('Carriers'))+(floor(config('IFFTLength')/4) -floor(config('Carriers')/2));%原复数数据对应坐标
Tx_data=OFDMTransiver(Baseband,carriers,config);%发射数据
Rx_data=OFDMChannel(Tx_data,config);%接收数据
Rx_decoded_signal=OFDMReceiver(Rx_data,carriers,config);%解码

if (config('plotEnable'))
    tFigureHandle=findobj(0,'Name','Bit Stream');
    if(isempty(tFigureHandle))
        tFigureHandle=  figure('Name','Bit Stream','NumberTitle','off');
    else
       figure(tFigureHandle)
    end
    movegui(tFigureHandle,'southwest');
    subplot(2,1,1);
    stem(Baseband(1:100));
    title('输出二进制比特流')
    subplot(2,1,2);
    stem(Rx_decoded_signal(1:100));
    title('解调二进制比特流')
end

%-------------------------------------------BER计算-------------------------------------------------
Errors=find(Rx_decoded_signal ~= Baseband);
Bit_Errors = size(Errors, 2);
BER=Bit_Errors/config('BasebandLength') ;
fprintf('\tBER=%g\n',BER);
