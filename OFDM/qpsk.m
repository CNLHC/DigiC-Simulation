function [QPSK_symbol]=QPSK(bit_stream)
%QPSK����
Temp=reshape(bit_stream,2,length(bit_stream)/2)';
source=zeros(length(bit_stream)/2,1);
QPSK_data=zeros(length(bit_stream)/2,2);
d=1;%����ͼ���굥λ����
for i=1:length(bit_stream)/2
    for j=1:2
        Temp(i,j)=Temp(i,j)*(2^(2-j));
    end
        source(i,1)=1+sum(Temp(i,:));%˫������Ԫӳ����1~4
end
mapping=[-d, d; d, d; d, -d; -d, -d];
 for i=1:length(bit_stream)/2
     QPSK_data(i,:)=mapping(source(i),:);%����ӳ��
 end
 QPSK_symbol=complex(QPSK_data(:,1),QPSK_data(:,2));
