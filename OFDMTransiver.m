function windowed_Tx_data=OFDMTransiver(baseband_out,conjugate_carriers,modulation)
%------------------------------------------------------------------------------------------------------
%                                                                  �����
%------------------------------------------------------------------------------------------------------
if (modulation==1)
%----------------------------------------------16QAM����-------------------------------------------
    complex_carrier_matrix=qam16(baseband_out);%���ƺ�����
    complex_carrier_matrix=reshape(complex_carrier_matrix',carrier_count,symbols_per_carrier)';%symbols_per_carrier*carrier_count ����
    if (plotEnable)
        figure('Name','16QAM Constellation Diagram','NumberTitle','off');
        plot(complex_carrier_matrix,'or');%16QAM���ƺ�����ͼ
        title('16QAM�����ź�����ͼ')
        axis square
        axis([-4, 4, -4, 4]);
        grid on
    end
else
%------------------------------------------------QPSK����-------------------------------------------
    complex_carrier_matrix=qpsk(baseband_out);
    complex_carrier_matrix=reshape(complex_carrier_matrix',carrier_count,symbols_per_carrier)';
    if (plotEnable)
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
end