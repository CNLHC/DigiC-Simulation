function [complex_qpsk_data]=qpsk(bitdata)
%QPSK调制
X1=reshape(bitdata,2,length(bitdata)/2)';
d=1;%星座图坐标单位长度
for i=1:length(bitdata)/2
    for j=1:2
        X1(i,j)=X1(i,j)*(2^(2-j));
    end
        source(i,1)=1+sum(X1(i,:));%双比特码元映射至1~4
end
mapping=[-d, d; d, d; d, -d; -d, -d];
 for i=1:length(bitdata)/2
     qpsk_data(i,:)=mapping(source(i),:);%数据映射
 end
 complex_qpsk_data=complex(qpsk_data(:,1),qpsk_data(:,2));
