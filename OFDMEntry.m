function BER=OFDMEntry(modulation, SNR, L, plot_config, SNR_test, CN, OP)
%Input:
    %modulation: Modulation method, 1=16QAM，0=QPSK
    %SNR: Signal Noise Ratio in dB
    %L: multipath number 
    %plot_config：plot selection, 1 = plot constellation diagram
%Output:
    %ber：
%----------------------------------------------------
carrier_count=1024;
symbols_per_carrier=8;
if (modulation==1)
    bits_per_symbol=4;%corresponding to 16-QAM modulation
else
    bits_per_symbol=2;%corresponding to QPSK modulation
end
IFFT_bin_length=2944;%FFT length
PrefixRatio=1/4;%cyclic prefix ratio of FFT length
CP=PrefixRatio*IFFT_bin_length ;%cyclic prefix length of each symbol
beta=1/32;%window function roll-off coefficient
CS=beta*(IFFT_bin_length+CP);%length after adding CP

%# Transisver
%## Signal Generation
baseband_out_length = carrier_count * symbols_per_carrier * bits_per_symbol;%total bits count
carriers = (1:carrier_count) + (floor(IFFT_bin_length/4) - floor(carrier_count/2));%共轭对称子载波映射，原复数数据对应坐标
conjugate_carriers = IFFT_bin_length - carriers + 2;%共轭对称子载波映射，共轭复数对应的IFFT点坐标
baseband_out=round(rand(1,baseband_out_length));%输出二进制比特流
if (modulation==1)
%16QAM
    complex_carrier_matrix=qam16(baseband_out);%调制后数据
    complex_carrier_matrix=reshape(complex_carrier_matrix',carrier_count,symbols_per_carrier)';%symbols_per_carrier*carrier_count 矩阵
    if (plot_config)
        figure('Name','16QAM Constellation Diagram','NumberTitle','off');
        plot(complex_carrier_matrix,'or');%16QAM调制后星座图
        title('16QAM Constellation Diagram')
        axis square
        axis([-4, 4, -4, 4]);
        grid on
    end
else
%QPSK
    complex_carrier_matrix=qpsk(baseband_out);
    complex_carrier_matrix=reshape(complex_carrier_matrix',carrier_count,symbols_per_carrier)';
    if (plot_config)
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
trainingSymbols = (tmpTable(floor( 4*rand(trainingSymbols_len,carrier_count))+1 ));%trainingSymbols_len*carrier_count矩阵
zero_padding=zeros(1,carrier_count);%插入一行零数据
complex_carrier_matrix=cat(1,zero_padding,complex_carrier_matrix);
complex_carrier_matrix=cat(1,trainingSymbols,complex_carrier_matrix);%块状导频，拼接在数据矩阵前
%----------------------------------------------------IFFT-------------------------------------------------
IFFT_modulation=zeros(symbols_per_carrier+trainingSymbols_len+1,IFFT_bin_length);%zeropadding
IFFT_modulation(:,carriers ) = complex_carrier_matrix ;%添加导频信号 ，映射原数据
IFFT_modulation(:,conjugate_carriers ) = conj(complex_carrier_matrix);%共轭复数映射，共轭拓展使IFFT输出实序列
signal_after_IFFT=ifft(IFFT_modulation,IFFT_bin_length,2);%OFDM调制，获得时域波形矩阵，行为每载波所含符号数+导频长度+1，列为IFFT点数
%-------------------------------------------添加循环前缀与后缀--------------------------------------------
TEMP=zeros(symbols_per_carrier+trainingSymbols_len+1,IFFT_bin_length+CP+CS);
for k=1:symbols_per_carrier+trainingSymbols_len+1
    for i=1:IFFT_bin_length
        TEMP(k,i+CP)=signal_after_IFFT(k,i);%OFDM信号映射
    end
    for i=1:CP
        TEMP(k,i)=signal_after_IFFT(k,i+IFFT_bin_length-CP);%添加循环前缀
    end
    for j=1:CS
        TEMP(k,IFFT_bin_length+CP+j)=signal_after_IFFT(k,j);%添加循环后缀
    end
end
time_wave_matrix_cp=TEMP;%添加了循环前缀与后缀的时域信号矩阵
%-------------------------------------------------OFDM符号加窗-----------------------------------------------------
windowed_time_wave_matrix_cp=zeros(symbols_per_carrier+trainingSymbols_len+1,IFFT_bin_length+CP+CS);
for i = 1:symbols_per_carrier+trainingSymbols_len+1
windowed_time_wave_matrix_cp(i,:) = real(time_wave_matrix_cp(i,:)).*rcoswindow(beta,IFFT_bin_length+CP)';%加升余弦窗
end  
%--------------------------------------------生成发送信号，并串变换----------------------------------------------------
windowed_Tx_data=zeros(1,(symbols_per_carrier+trainingSymbols_len+1)*(IFFT_bin_length+CP)+CS);%++
windowed_Tx_data(1:IFFT_bin_length+CP+CS)=windowed_time_wave_matrix_cp(1,:);
for i = 1:symbols_per_carrier+trainingSymbols_len+1-1 %++
    windowed_Tx_data((IFFT_bin_length+CP)*i+1:(IFFT_bin_length+CP)*(i+1)+CS)=windowed_time_wave_matrix_cp(i+1,:);
    %并串转换，循环后缀与循环前缀相叠加
end
%------------------------------------------------频率选择信道------------------------------------------------------
size_Tx=size(windowed_Tx_data,2);
delay=1;%第L条信道时延为(L-1)/W，对应序列平移一位
multipath_Tx_data=zeros(1,size_Tx);

if(L>=1&&(~SNR_test))
    for i=1:L
    temp=zeros(1,size_Tx);
    temp(delay*(i-1)+1:size_Tx)=windowed_Tx_data(1:size_Tx-delay*(i-1));
    multipath_Tx_data=multipath_Tx_data+temp*sqrt(1/(2*L))*(randn(1)+1i*randn(1));%叠加各个时延信号，信道符合CN(0,1/L)
    end
elseif (L>=1&&SNR_test)
    for i=1:L
    temp=zeros(1,size_Tx);
    temp(delay*(i-1)+1:size_Tx)=windowed_Tx_data(1:size_Tx-delay*(i-1));
    multipath_Tx_data=multipath_Tx_data+temp*sqrt(1/(2*L))*CN(i);%叠加各个时延信号，信道符合CN(0,1/L)
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
noise=randn(1,((symbols_per_carrier+trainingSymbols_len+1)*(IFFT_bin_length+CP))+CS)*noise_scaling_factor;%产生AWGN
Rx_data=multipath_Tx_data+noise;%叠加AWGN
%------------------------------------------------------------------------------------------------------
%                                                                  接收端
%------------------------------------------------------------------------------------------------------
%----------------------------------串/并变换 去除前缀与后缀 OFDM解调---------------------------
Rx_data_matrix=zeros(symbols_per_carrier+trainingSymbols_len+1,IFFT_bin_length+CP+CS);
for i=1:symbols_per_carrier+trainingSymbols_len+1
    Rx_data_matrix(i,:)=Rx_data(1,(i-1)*(IFFT_bin_length+CP)+1:i*(IFFT_bin_length+CP)+CS);%串并变换
end
Rx_data_complex_matrix=Rx_data_matrix(:,CP+1:IFFT_bin_length+CP);%去除循环前缀与循环后缀，得到有用信号矩阵
Y1=fft(Rx_data_complex_matrix,IFFT_bin_length,2);%FFT变换，OFDM解码
%------------------------------------------频域均衡--------------------------------------------------
Rx_carriers=Y1(:,carriers);%去除保护间隔与共轭数据
RxTrainSymbols = Rx_carriers((1: trainingSymbols_len),: );%提取导频
H = RxTrainSymbols./ trainingSymbols;%信道估计
if (isnan(OP)) 
    OP=1;
end
if(OP)
    H_2 = abs(H).^2;
    H_2 = sum(H_2,1);%取均值减小误差
    H_C2 = sum(H,1);
    H_C2 = conj(H_C2);
    H = H_C2./H_2 ;    % 1/H = conj(H)/abs(H)^2
    Rx2 = ones(size(Rx_carriers,1),1)*H.*Rx_carriers;%Y=X*H, X=Y*1/H，单抽头均衡
else
    Rx2 = Rx_carriers;
end
Rx = Rx2((trainingSymbols_len+1+1:size(Rx2,1)),:);%去除导频，提取调制信号
Rx_phase =angle(Rx);%接收信号的相位
Rx_mag = abs(Rx);%接收信号的幅度
if (plot_config)
    figure('Name','RX Constellation Diagram I','NumberTitle','off');
    polarplot(Rx_phase, Rx_mag,'bd');%极坐标下接收信号的星座图
    title('RX信号的星座图（极坐标）')
    rlim([0, 10])
end

[M, N]=pol2cart(Rx_phase, Rx_mag); 
Rx_complex_carrier_matrix = complex(M, N);

if (plot_config)
    figure('Name','RX Constellation Diagram II','NumberTitle','off');
    plot(Rx_complex_carrier_matrix,'*b');%直角坐标下接收信号的星座图
    title('RX信号星座图（直角坐标）')
    axis square
    axis([-4, 4, -4, 4]);
    grid on
end
%------------------------------------------16QAM，QPSK解调--------------------------------------------------
Rx_serial_complex_symbols=reshape(Rx_complex_carrier_matrix',size(Rx_complex_carrier_matrix, 1)*size(Rx_complex_carrier_matrix,2),1)' ;
if (modulation==1)
    Rx_decoded_binary_symbols=demoduqam16(Rx_serial_complex_symbols);%16QAM
else
    Rx_decoded_binary_symbols=demoduqpsk(Rx_serial_complex_symbols);%QPSK
end
%-------------------------------------------比特流可视化-------------------------------------------------
baseband_in = Rx_decoded_binary_symbols;
if (plot_config)
    figure('Name','Bit Stream','NumberTitle','off');
    subplot(2,1,1);
    stem(baseband_out(1:100));
    title('输出二进制比特流')
    subplot(2,1,2);
    stem(baseband_in(1:100));
    title('解调二进制比特流')
end
%-------------------------------------------误码率计算-------------------------------------------------
bit_errors=find(baseband_in ~=baseband_out);
Bit_Errors = size(bit_errors, 2)
BER=Bit_Errors/baseband_out_length
