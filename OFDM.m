function BER=OFDM(config,Baseband)

fprintf("OFDM-Session:\n\tSNR=%g\n\tPath:%d\n",config('SNR'),config('L'));
carriers = (1:config('Carriers'))+(floor(config('IFFTLength')/4) -floor(config('Carriers')/2));%ԭ�������ݶ�Ӧ����
Tx_data=OFDMTransiver(Baseband,carriers,config);%��������
Rx_data=OFDMChannel(Tx_data,config);%��������
Rx_decoded_signal=OFDMReceiver(Rx_data,carriers,config);%����

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
    title('��������Ʊ�����')
    subplot(2,1,2);
    stem(Rx_decoded_signal(1:100));
    title('��������Ʊ�����')
end

%-------------------------------------------BER����-------------------------------------------------
Errors=find(Rx_decoded_signal ~= Baseband);
Bit_Errors = size(Errors, 2);
BER=Bit_Errors/config('BasebandLength') ;
fprintf('\tBER=%g\n',BER);
