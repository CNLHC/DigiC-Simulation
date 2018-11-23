function [QPSK_symbol]=QPSK(bit_stream)
%QPSK调制
Temp=reshape(bit_stream,2,length(bit_stream)/2)';
source=zeros(length(bit_stream)/2,1);
QPSK_data=zeros(length(bit_stream)/2,2);
d=1;%星座图坐标单位长度
for i=1:length(bit_stream)/2
    for j=1:2
        Temp(i,j)=Temp(i,j)*(2^(2-j));
    end
        source(i,1)=1+sum(Temp(i,:));%双比特码元映射至1~4
end
mapping=[-d, d; d, d; d, -d; -d, -d];
 for i=1:length(bit_stream)/2
     QPSK_data(i,:)=mapping(source(i),:);%数据映射
 end
 QPSK_symbol=complex(QPSK_data(:,1),QPSK_data(:,2));
