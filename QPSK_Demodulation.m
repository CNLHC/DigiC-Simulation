function [demodulated_symbol]=QPSK_Demodulation(Rx_symbols)
%将得到的串行QPSK数据解调成二进制比特流
complex_symbols=reshape(Rx_symbols,length(Rx_symbols),1);
d=1;
mapping=[-d, d; d, d; d, -d;  -d, -d ];
  complex_mapping=complex(mapping(:,1),mapping(:,2));
  for i=1:length(Rx_symbols)
      for j=1:4
          distance(j)=abs(complex_symbols(i,1)-complex_mapping(j,1));
      end
      [min_metric  min_distance(i)]= min(distance) ;  
  end
  
  decoded_symbol=de2bi((min_distance-1)','left-msb');
  demodulated_symbol=reshape(decoded_symbol',1,length(Rx_symbols)*2);
