function BER=OFDMEntry(modulation, SNR, L, plot_config, SNR_test, CN, OP)
%Input:
    %modulation: Modulation method, 1=16QAM��0=QPSK
    %SNR: Signal Noise Ratio in dB
    %L: multipath number 
    %plot_config��plot selection, 1 = plot constellation diagram
%Output:
    %ber��
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
carriers = (1:carrier_count) + (floor(IFFT_bin_length/4) - floor(carrier_count/2));%����Գ����ز�ӳ�䣬ԭ�������ݶ�Ӧ����
conjugate_carriers = IFFT_bin_length - carriers + 2;%����Գ����ز�ӳ�䣬�������Ӧ��IFFT������
baseband_out=round(rand(1,baseband_out_length));%��������Ʊ�����
if (modulation==1)
%16QAM
    complex_carrier_matrix=qam16(baseband_out);%���ƺ�����
    complex_carrier_matrix=reshape(complex_carrier_matrix',carrier_count,symbols_per_carrier)';%symbols_per_carrier*carrier_count ����
    if (plot_config)
        figure('Name','16QAM Constellation Diagram','NumberTitle','off');
        plot(complex_carrier_matrix,'or');%16QAM���ƺ�����ͼ
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
        plot(complex_carrier_matrix,'or');%QPSK���ƺ�����ͼ
        title('QPSK�����ź�����ͼ')
        axis square
        axis([-2, 2, -2, 2]);
        grid on
    end
end

%---------------------------------------------------��Ƶ------------------------------------------------
tmpTable = [-1,1,1i,-1i];%��Ƶ����Ϊ-1 1 -i i��ѡȡ���������
trainingSymbols_len =4;%��Ƶ����
trainingSymbols = (tmpTable(floor( 4*rand(trainingSymbols_len,carrier_count))+1 ));%trainingSymbols_len*carrier_count����
zero_padding=zeros(1,carrier_count);%����һ��������
complex_carrier_matrix=cat(1,zero_padding,complex_carrier_matrix);
complex_carrier_matrix=cat(1,trainingSymbols,complex_carrier_matrix);%��״��Ƶ��ƴ�������ݾ���ǰ
%----------------------------------------------------IFFT-------------------------------------------------
IFFT_modulation=zeros(symbols_per_carrier+trainingSymbols_len+1,IFFT_bin_length);%zeropadding
IFFT_modulation(:,carriers ) = complex_carrier_matrix ;%��ӵ�Ƶ�ź� ��ӳ��ԭ����
IFFT_modulation(:,conjugate_carriers ) = conj(complex_carrier_matrix);%�����ӳ�䣬������չʹIFFT���ʵ����
signal_after_IFFT=ifft(IFFT_modulation,IFFT_bin_length,2);%OFDM���ƣ����ʱ���ξ�����Ϊÿ�ز�����������+��Ƶ����+1����ΪIFFT����
%-------------------------------------------���ѭ��ǰ׺���׺--------------------------------------------
TEMP=zeros(symbols_per_carrier+trainingSymbols_len+1,IFFT_bin_length+CP+CS);
for k=1:symbols_per_carrier+trainingSymbols_len+1
    for i=1:IFFT_bin_length
        TEMP(k,i+CP)=signal_after_IFFT(k,i);%OFDM�ź�ӳ��
    end
    for i=1:CP
        TEMP(k,i)=signal_after_IFFT(k,i+IFFT_bin_length-CP);%���ѭ��ǰ׺
    end
    for j=1:CS
        TEMP(k,IFFT_bin_length+CP+j)=signal_after_IFFT(k,j);%���ѭ����׺
    end
end
time_wave_matrix_cp=TEMP;%�����ѭ��ǰ׺���׺��ʱ���źž���
%-------------------------------------------------OFDM���żӴ�-----------------------------------------------------
windowed_time_wave_matrix_cp=zeros(symbols_per_carrier+trainingSymbols_len+1,IFFT_bin_length+CP+CS);
for i = 1:symbols_per_carrier+trainingSymbols_len+1
windowed_time_wave_matrix_cp(i,:) = real(time_wave_matrix_cp(i,:)).*rcoswindow(beta,IFFT_bin_length+CP)';%�������Ҵ�
end  
%--------------------------------------------���ɷ����źţ������任----------------------------------------------------
windowed_Tx_data=zeros(1,(symbols_per_carrier+trainingSymbols_len+1)*(IFFT_bin_length+CP)+CS);%++
windowed_Tx_data(1:IFFT_bin_length+CP+CS)=windowed_time_wave_matrix_cp(1,:);
for i = 1:symbols_per_carrier+trainingSymbols_len+1-1 %++
    windowed_Tx_data((IFFT_bin_length+CP)*i+1:(IFFT_bin_length+CP)*(i+1)+CS)=windowed_time_wave_matrix_cp(i+1,:);
    %����ת����ѭ����׺��ѭ��ǰ׺�����
end
%------------------------------------------------Ƶ��ѡ���ŵ�------------------------------------------------------
size_Tx=size(windowed_Tx_data,2);
delay=1;%��L���ŵ�ʱ��Ϊ(L-1)/W����Ӧ����ƽ��һλ
multipath_Tx_data=zeros(1,size_Tx);

if(L>=1&&(~SNR_test))
    for i=1:L
    temp=zeros(1,size_Tx);
    temp(delay*(i-1)+1:size_Tx)=windowed_Tx_data(1:size_Tx-delay*(i-1));
    multipath_Tx_data=multipath_Tx_data+temp*sqrt(1/(2*L))*(randn(1)+1i*randn(1));%���Ӹ���ʱ���źţ��ŵ�����CN(0,1/L)
    end
elseif (L>=1&&SNR_test)
    for i=1:L
    temp=zeros(1,size_Tx);
    temp(delay*(i-1)+1:size_Tx)=windowed_Tx_data(1:size_Tx-delay*(i-1));
    multipath_Tx_data=multipath_Tx_data+temp*sqrt(1/(2*L))*CN(i);%���Ӹ���ʱ���źţ��ŵ�����CN(0,1/L)
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
noise=randn(1,((symbols_per_carrier+trainingSymbols_len+1)*(IFFT_bin_length+CP))+CS)*noise_scaling_factor;%����AWGN
Rx_data=multipath_Tx_data+noise;%����AWGN
%------------------------------------------------------------------------------------------------------
%                                                                  ���ն�
%------------------------------------------------------------------------------------------------------
%----------------------------------��/���任 ȥ��ǰ׺���׺ OFDM���---------------------------
Rx_data_matrix=zeros(symbols_per_carrier+trainingSymbols_len+1,IFFT_bin_length+CP+CS);
for i=1:symbols_per_carrier+trainingSymbols_len+1
    Rx_data_matrix(i,:)=Rx_data(1,(i-1)*(IFFT_bin_length+CP)+1:i*(IFFT_bin_length+CP)+CS);%�����任
end
Rx_data_complex_matrix=Rx_data_matrix(:,CP+1:IFFT_bin_length+CP);%ȥ��ѭ��ǰ׺��ѭ����׺���õ������źž���
Y1=fft(Rx_data_complex_matrix,IFFT_bin_length,2);%FFT�任��OFDM����
%------------------------------------------Ƶ�����--------------------------------------------------
Rx_carriers=Y1(:,carriers);%ȥ����������빲������
RxTrainSymbols = Rx_carriers((1: trainingSymbols_len),: );%��ȡ��Ƶ
H = RxTrainSymbols./ trainingSymbols;%�ŵ�����
if (isnan(OP)) 
    OP=1;
end
if(OP)
    H_2 = abs(H).^2;
    H_2 = sum(H_2,1);%ȡ��ֵ��С���
    H_C2 = sum(H,1);
    H_C2 = conj(H_C2);
    H = H_C2./H_2 ;    % 1/H = conj(H)/abs(H)^2
    Rx2 = ones(size(Rx_carriers,1),1)*H.*Rx_carriers;%Y=X*H, X=Y*1/H������ͷ����
else
    Rx2 = Rx_carriers;
end
Rx = Rx2((trainingSymbols_len+1+1:size(Rx2,1)),:);%ȥ����Ƶ����ȡ�����ź�
Rx_phase =angle(Rx);%�����źŵ���λ
Rx_mag = abs(Rx);%�����źŵķ���
if (plot_config)
    figure('Name','RX Constellation Diagram I','NumberTitle','off');
    polarplot(Rx_phase, Rx_mag,'bd');%�������½����źŵ�����ͼ
    title('RX�źŵ�����ͼ�������꣩')
    rlim([0, 10])
end

[M, N]=pol2cart(Rx_phase, Rx_mag); 
Rx_complex_carrier_matrix = complex(M, N);

if (plot_config)
    figure('Name','RX Constellation Diagram II','NumberTitle','off');
    plot(Rx_complex_carrier_matrix,'*b');%ֱ�������½����źŵ�����ͼ
    title('RX�ź�����ͼ��ֱ�����꣩')
    axis square
    axis([-4, 4, -4, 4]);
    grid on
end
%------------------------------------------16QAM��QPSK���--------------------------------------------------
Rx_serial_complex_symbols=reshape(Rx_complex_carrier_matrix',size(Rx_complex_carrier_matrix, 1)*size(Rx_complex_carrier_matrix,2),1)' ;
if (modulation==1)
    Rx_decoded_binary_symbols=demoduqam16(Rx_serial_complex_symbols);%16QAM
else
    Rx_decoded_binary_symbols=demoduqpsk(Rx_serial_complex_symbols);%QPSK
end
%-------------------------------------------���������ӻ�-------------------------------------------------
baseband_in = Rx_decoded_binary_symbols;
if (plot_config)
    figure('Name','Bit Stream','NumberTitle','off');
    subplot(2,1,1);
    stem(baseband_out(1:100));
    title('��������Ʊ�����')
    subplot(2,1,2);
    stem(baseband_in(1:100));
    title('��������Ʊ�����')
end
%-------------------------------------------�����ʼ���-------------------------------------------------
bit_errors=find(baseband_in ~=baseband_out);
Bit_Errors = size(bit_errors, 2)
BER=Bit_Errors/baseband_out_length
