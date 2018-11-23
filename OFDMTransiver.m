function Tx_data=OFDMTransiver(Baseband,carriers,config)
conjugate_carriers = config('IFFTLength') - carriers + 2;%����Գ�ӳ��

if (config('using16QAM')==1)
%----------------------------------------------16QAM����-------------------------------------------
    carrier_symbols=QAM16(Baseband);%���ƺ�����
    carrier_symbols=reshape(carrier_symbols',config('Carriers'),config('SymbolsPerCarrier'))';%SymbolsPerCarrier*carrier_count
    if (config('plotEnable'))
        tFigureHandle=findobj(0,'Name','QPSK Constellation Diagra');
        if(isempty(tFigureHandle))
            tFigureHandle=figure('Name','16QAM Constellation Diagram','NumberTitle','off');
        else
           figure(tFigureHandle)
        end
        movegui(tFigureHandle,'northwest');
        plot(carrier_symbols,'or');%16QAM���ƺ�����ͼ
        title('16QAM�����ź�����ͼ')
        axis square
        axis([-4, 4, -4, 4]);
        grid on
    end
else
%------------------------------------------------QPSK����-------------------------------------------
    carrier_symbols=QPSK(Baseband);
    carrier_symbols=reshape(carrier_symbols',config('Carriers'),config('SymbolsPerCarrier'))';
    if (config('plotEnable'))
        tFigureHandle=findobj(0,'Name','QPSK Constellation Diagram');
        if(isempty(tFigureHandle))
           tFigureHandle=figure('Name','QPSK Constellation Diagram','NumberTitle','off');
        else
           figure(tFigureHandle)
        end
        movegui(tFigureHandle,'northwest');
        plot(carrier_symbols,'or');%QPSK���ƺ�����ͼ
        title('QPSK�����ź�����ͼ')
        axis square
        axis([-2, 2, -2, 2]);
        grid on
    end
end
%---------------------------------------------------��Ƶ------------------------------------------------
trainingSymbols_len=config('TrainingSymbolsLength');
trainingSymbols=config('trainingSymbols');
zero_padding=zeros(1,config('Carriers'));%����һ��������
carrier_symbols=cat(1,zero_padding,carrier_symbols);
carrier_symbols=cat(1,trainingSymbols,carrier_symbols);%��״��Ƶ��ƴ�������ݾ���ǰ
%----------------------------------------------------IFFT-------------------------------------------------
IFFT_output=zeros(config('SymbolsPerCarrier')+trainingSymbols_len+1,config('IFFTLength'));%zeropadding
IFFT_output(:,carriers ) = carrier_symbols ;%��ӵ�Ƶ�ź� ��ӳ��ԭ����
IFFT_output(:,conjugate_carriers ) = conj(carrier_symbols);%�����ӳ�䣬������չʹIFFT���ʵ����
signal_after_IFFT=ifft(IFFT_output,config('IFFTLength'),2);%OFDM���ƣ����ʱ�������Ϊÿ�ز�����������+��Ƶ����+1����ΪIFFT����
%-------------------------------------------���ѭ��ǰ׺���׺--------------------------------------------
TEMP=zeros(config('SymbolsPerCarrier')+trainingSymbols_len+1,config('IFFTLength')+config('CPLength')+config('CSLength'));
for k=1:config('SymbolsPerCarrier')+trainingSymbols_len+1
    for i=1:config('IFFTLength')
        TEMP(k,i+config('CPLength'))=signal_after_IFFT(k,i);%OFDM�ź�ӳ��
    end
    for i=1:config('CPLength')
        TEMP(k,i)=signal_after_IFFT(k,i+config('IFFTLength')-config('CPLength'));%���ѭ��ǰ׺
    end
    for j=1:config('CSLength')
        TEMP(k,config('IFFTLength')+config('CPLength')+j)=signal_after_IFFT(k,j);%���ѭ����׺
    end
end
symbols_with_CP=TEMP;%�����ѭ��ǰ׺���׺��ʱ���źž���
%-------------------------------------------------OFDM���żӴ�-----------------------------------------------------
windowed_symbols=zeros(config('SymbolsPerCarrier')+trainingSymbols_len+1,config('IFFTLength')+config('CPLength')+config('CSLength'));
for i = 1:config('SymbolsPerCarrier')+trainingSymbols_len+1
windowed_symbols(i,:) = real(symbols_with_CP(i,:)).*Window(config('beta'),config('IFFTLength')+config('CPLength'))';%�Ӵ�
end  
%--------------------------------------------���ɷ����źţ������任----------------------------------------------------
Tx_data=zeros(1,(config('SymbolsPerCarrier')+trainingSymbols_len+1)*(config('IFFTLength')+config('CPLength'))+config('CSLength'));
Tx_data(1:config('IFFTLength')+config('CPLength')+config('CSLength') )=windowed_symbols(1,:);
for i = 1:config('SymbolsPerCarrier')+trainingSymbols_len+1-1 
    Tx_data((config('IFFTLength')+config('CPLength'))*i+1:(config('IFFTLength')+config('CPLength'))*(i+1)+config('CSLength'))=windowed_symbols(i+1,:);
    %����ת��
end
end