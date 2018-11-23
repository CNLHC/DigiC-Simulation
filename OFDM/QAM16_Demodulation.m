function [demodulated_symbol]=QAM16_Demodulation(Rx_symbols)
%将得到的串行16QAM数据解调成二进制比特流
complex_symbols=reshape(Rx_symbols,length(Rx_symbols),1);
d=1;
mapping=[   d,d;         d,3*d;        d,-d;       d,-3*d;
                    3*d,d;     3*d,3*d;     3*d,-d;    3*d,-3*d;
 	                -d,d;       -d,3*d;        -d,-d;       -d,-3*d;
	               -3*d,d;   -3*d,3*d;    -3*d,-d;    -3*d,-3*d];%16QAM映射
  complex_mapping=complex(mapping(:,1),mapping(:,2));
  for i=1:length(Rx_symbols)
      for j=1:16
          distance(j)=abs(complex_symbols(i,1)-complex_mapping(j,1));
      end
      [min_metric  min_distance(i)]= min(distance) ; 
  end
  
  decoded_symbol=de2bi((min_distance-1)','left-msb');
  demodulated_symbol=reshape(decoded_symbol',1,length(Rx_symbols)*4);
