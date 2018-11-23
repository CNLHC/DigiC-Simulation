function [complex_qpsk_data]=qpsk(bitdata)
%QPSK����
X1=reshape(bitdata,2,length(bitdata)/2)';
d=1;%����ͼ���굥λ����
for i=1:length(bitdata)/2
    for j=1:2
        X1(i,j)=X1(i,j)*(2^(2-j));
    end
        source(i,1)=1+sum(X1(i,:));%˫������Ԫӳ����1~4
end
mapping=[-d, d; d, d; d, -d; -d, -d];
 for i=1:length(bitdata)/2
     qpsk_data(i,:)=mapping(source(i),:);%����ӳ��
 end
 complex_qpsk_data=complex(qpsk_data(:,1),qpsk_data(:,2));
