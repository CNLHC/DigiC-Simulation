function [demodu_bit_symbol]=demoduqam16(Rx_serial_complex_symbols)
%将得到的串行16QAM数据解调成二进制比特流
complex_symbols=reshape(Rx_serial_complex_symbols,length(Rx_serial_complex_symbols),1);
d=1;
mapping=[   d,d;         d,3*d;        d,-d;       d,-3*d;
                    3*d,d;     3*d,3*d;     3*d,-d;    3*d,-3*d;
 	                -d,d;       -d,3*d;        -d,-d;       -d,-3*d;
	               -3*d,d;   -3*d,3*d;    -3*d,-d;    -3*d,-3*d];%16QAM映射
  complex_mapping=complex(mapping(:,1),mapping(:,2));
  for i=1:length(Rx_serial_complex_symbols)
      for j=1:16
          metrics(j)=abs(complex_symbols(i,1)-complex_mapping(j,1));
      end
      [min_metric  decode_symbol(i)]= min(metrics) ;  %将离某星座点最近的值赋给decode_symbol(i)
  end
  
  decode_bit_symbol=de2bi((decode_symbol-1)','left-msb');
  demodu_bit_symbol=reshape(decode_bit_symbol',1,length(Rx_serial_complex_symbols)*4);
