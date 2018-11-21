function windowed_Tx_data=OFDMTransiver(baseband_out,carriers,config)
%------------------------------------------------------------------------------------------------------
%                                                                  发射端
%------------------------------------------------------------------------------------------------------
conjugate_carriers = config('IFFTBinLength') - carriers + 2;%共轭对称子载波映射，共轭复数对应的IFFT点坐标

if (config('using16QAM')==1)
%----------------------------------------------16QAM调制-------------------------------------------
    complex_carrier_matrix=qam16(baseband_out);%调制后数据
    complex_carrier_matrix=reshape(complex_carrier_matrix',config('carrierCounts'),config('symbolsPerCarrier'))';%symbols_per_carrier*carrier_count 矩阵
    if (config('plotEnable'))
        figure('Name','16QAM Constellation Diagram','NumberTitle','off');
        plot(complex_carrier_matrix,'or');%16QAM调制后星座图
        title('16QAM调制信号星座图')
        axis square
        axis([-4, 4, -4, 4]);
        grid on
    end
else
%------------------------------------------------QPSK调制-------------------------------------------
    complex_carrier_matrix=qpsk(baseband_out);
    complex_carrier_matrix=reshape(complex_carrier_matrix',config('carrierCounts'),config('symbolsPerCarrier'))';
    if (config('plotEnable'))
        figure('Name','QPSK Constellation Diagram','NumberTitle','off');
        plot(complex_carrier_matrix,'or');%QPSK调制后星座图
        title('QPSK调制信号星座图')
        axis square
        axis([-2, 2, -2, 2]);
        grid on
    end
end
%---------------------------------------------------导频------------------------------------------------
tmpTable = [-1,1,1i,-1i];%导频数据为-1 1 -i i中选取的随机序列
trainingSymbols_len =4;%导频长度
trainingSymbols = (tmpTable(floor( 4*rand(trainingSymbols_len,config('carrierCounts')))+1 ));%trainingSymbols_len*carrier_count矩阵
zero_padding=zeros(1,config('carrierCounts'));%插入一行零数据
complex_carrier_matrix=cat(1,zero_padding,complex_carrier_matrix);
complex_carrier_matrix=cat(1,trainingSymbols,complex_carrier_matrix);%块状导频，拼接在数据矩阵前
%----------------------------------------------------IFFT-------------------------------------------------
IFFT_modulation=zeros(config('symbolsPerCarrier')+trainingSymbols_len+1,config('IFFTBinLength'));%zeropadding
IFFT_modulation(:,carriers ) = complex_carrier_matrix ;%添加导频信号 ，映射原数据
IFFT_modulation(:,conjugate_carriers ) = conj(complex_carrier_matrix);%共轭复数映射，共轭拓展使IFFT输出实序列
signal_after_IFFT=ifft(IFFT_modulation,config('IFFTBinLength'),2);%OFDM调制，获得时域波形矩阵，行为每载波所含符号数+导频长度+1，列为IFFT点数
%-------------------------------------------添加循环前缀与后缀--------------------------------------------
TEMP=zeros(config('symbolsPerCarrier')+trainingSymbols_len+1,config('IFFTBinLength')+config('CPLength')+config('CSLength'));
for k=1:config('symbolsPerCarrier')+trainingSymbols_len+1
    for i=1:config('IFFTBinLength')
        TEMP(k,i+config('CPLength'))=signal_after_IFFT(k,i);%OFDM信号映射
    end
    for i=1:config('CPLength')
        TEMP(k,i)=signal_after_IFFT(k,i+config('IFFTBinLength')-config('CPLength'));%添加循环前缀
    end
    for j=1:config('CSLength')
        TEMP(k,config('IFFTBinLength')+config('CPLength')+j)=signal_after_IFFT(k,j);%添加循环后缀
    end
end
time_wave_matrix_cp=TEMP;%添加了循环前缀与后缀的时域信号矩阵
%-------------------------------------------------OFDM符号加窗-----------------------------------------------------
windowed_time_wave_matrix_cp=zeros(config('symbolsPerCarrier')+trainingSymbols_len+1,config('IFFTBinLength')+config('CPLength')+config('CSLength'));
for i = 1:config('symbolsPerCarrier')+trainingSymbols_len+1
windowed_time_wave_matrix_cp(i,:) = real(time_wave_matrix_cp(i,:)).*rcoswindow(config('beta'),config('IFFTBinLength')+config('CPLength'))';%加升余弦窗
end  
%--------------------------------------------生成发送信号，并串变换----------------------------------------------------
windowed_Tx_data=zeros(1,(config('symbolsPerCarrier')+trainingSymbols_len+1)*(config('IFFTBinLength')+config('CPLength'))+config('CSLength'));%++
windowed_Tx_data(1:config('IFFTBinLength')+config('CPLength')+config('CSLength') )=windowed_time_wave_matrix_cp(1,:);
for i = 1:config('symbolsPerCarrier')+trainingSymbols_len+1-1 %++
    windowed_Tx_data((config('IFFTBinLength')+config('CPLength'))*i+1:(config('IFFTBinLength')+config('CPLength'))*(i+1)+config('CSLength'))=windowed_time_wave_matrix_cp(i+1,:);
    %并串转换，循环后缀与循环前缀相叠加
end
end