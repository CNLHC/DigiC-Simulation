function [QAM_symbol]=QAM16(bit_stream)
%16QAM����
Temp=reshape(bit_stream,4,length(bit_stream)/4)';
source=zeros(length(bit_stream)/4,1);
QAM_data=zeros(length(bit_stream)/4,2);
d=1;%����ͼ���굥λ���� 
for i=1:length(bit_stream)/4
    for j=1:4
        Temp(i,j)=Temp(i,j)*(2^(4-j));
    end
        source(i,1)=1+sum(Temp(i,:));%�ı�����Ԫӳ����1~16
end
mapping=[   d,d;         d,3*d;        d,-d;       d,-3*d;
                    3*d,d;     3*d,3*d;     3*d,-d;    3*d,-3*d;
 	                -d,d;       -d,3*d;        -d,-d;       -d,-3*d;
	               -3*d,d;   -3*d,3*d;    -3*d,-d;    -3*d,-3*d];
               
 for i=1:length(bit_stream)/4
     QAM_data(i,:)=mapping(source(i),:);%����ӳ��
 end
 QAM_symbol=complex(QAM_data(:,1),QAM_data(:,2));
