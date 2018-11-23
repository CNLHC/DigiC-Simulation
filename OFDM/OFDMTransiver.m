function Tx_data=OFDMTransiver(Baseband,carriers,config)
conjugate_carriers = config('IFFTLength') - carriers + 2;%共轭对称映射

if (config('using16QAM')==1)
%----------------------------------------------16QAM调制-------------------------------------------
    carrier_symbols=QAM16(Baseband);%调制后数据
    carrier_symbols=reshape(carrier_symbols',config('Carriers'),config('SymbolsPerCarrier'))';%SymbolsPerCarrier*carrier_count
    if (config('plotEnable'))
        tFigureHandle=findobj(0,'Name','QPSK Constellation Diagra');
        if(isempty(tFigureHandle))
            tFigureHandle=figure('Name','16QAM Constellation Diagram','NumberTitle','off');
        else
           figure(tFigureHandle)
        end
        movegui(tFigureHandle,'northwest');
        plot(carrier_symbols,'or');%16QAM调制后星座图
        title('16QAM调制信号星座图')
        axis square
        axis([-4, 4, -4, 4]);
        grid on
    end
else
%------------------------------------------------QPSK调制-------------------------------------------
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
        plot(carrier_symbols,'or');%QPSK调制后星座图
        title('QPSK调制信号星座图')
        axis square
        axis([-2, 2, -2, 2]);
        grid on
    end
end
%---------------------------------------------------导频------------------------------------------------
trainingSymbols_len=config('TrainingSymbolsLength');
trainingSymbols=config('trainingSymbols');
zero_padding=zeros(1,config('Carriers'));%插入一行零数据
carrier_symbols=cat(1,zero_padding,carrier_symbols);
carrier_symbols=cat(1,trainingSymbols,carrier_symbols);%块状导频，拼接在数据矩阵前
%----------------------------------------------------IFFT-------------------------------------------------
IFFT_output=zeros(config('SymbolsPerCarrier')+trainingSymbols_len+1,config('IFFTLength'));%zeropadding
IFFT_output(:,carriers ) = carrier_symbols ;%添加导频信号 ，映射原数据
IFFT_output(:,conjugate_carriers ) = conj(carrier_symbols);%共轭复数映射，共轭拓展使IFFT输出实序列
signal_after_IFFT=ifft(IFFT_output,config('IFFTLength'),2);%OFDM调制，获得时域矩阵，行为每载波所含符号数+导频长度+1，列为IFFT点数
%-------------------------------------------添加循环前缀与后缀--------------------------------------------
TEMP=zeros(config('SymbolsPerCarrier')+trainingSymbols_len+1,config('IFFTLength')+config('CPLength')+config('CSLength'));
for k=1:config('SymbolsPerCarrier')+trainingSymbols_len+1
    for i=1:config('IFFTLength')
        TEMP(k,i+config('CPLength'))=signal_after_IFFT(k,i);%OFDM信号映射
    end
    for i=1:config('CPLength')
        TEMP(k,i)=signal_after_IFFT(k,i+config('IFFTLength')-config('CPLength'));%添加循环前缀
    end
    for j=1:config('CSLength')
        TEMP(k,config('IFFTLength')+config('CPLength')+j)=signal_after_IFFT(k,j);%添加循环后缀
    end
end
symbols_with_CP=TEMP;%添加了循环前缀与后缀的时域信号矩阵
%-------------------------------------------------OFDM符号加窗-----------------------------------------------------
windowed_symbols=zeros(config('SymbolsPerCarrier')+trainingSymbols_len+1,config('IFFTLength')+config('CPLength')+config('CSLength'));
for i = 1:config('SymbolsPerCarrier')+trainingSymbols_len+1
windowed_symbols(i,:) = real(symbols_with_CP(i,:)).*Window(config('beta'),config('IFFTLength')+config('CPLength'))';%加窗
end  
%--------------------------------------------生成发送信号，并串变换----------------------------------------------------
Tx_data=zeros(1,(config('SymbolsPerCarrier')+trainingSymbols_len+1)*(config('IFFTLength')+config('CPLength'))+config('CSLength'));
Tx_data(1:config('IFFTLength')+config('CPLength')+config('CSLength') )=windowed_symbols(1,:);
for i = 1:config('SymbolsPerCarrier')+trainingSymbols_len+1-1 
    Tx_data((config('IFFTLength')+config('CPLength'))*i+1:(config('IFFTLength')+config('CPLength'))*(i+1)+config('CSLength'))=windowed_symbols(i+1,:);
    %并串转换
end
end