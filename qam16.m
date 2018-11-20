function [complex_qam_data]=qam16(bitdata)
%16QAM����
X1=reshape(bitdata,4,length(bitdata)/4)';
d=1;%����ͼ���굥λ���� 
for i=1:length(bitdata)/4
    for j=1:4
        X1(i,j)=X1(i,j)*(2^(4-j));
    end
        source(i,1)=1+sum(X1(i,:));%�ı�����Ԫӳ����1~16
end
mapping=[   d,d;         d,3*d;        d,-d;       d,-3*d;
                    3*d,d;     3*d,3*d;     3*d,-d;    3*d,-3*d;
 	                -d,d;       -d,3*d;        -d,-d;       -d,-3*d;
	               -3*d,d;   -3*d,3*d;    -3*d,-d;    -3*d,-3*d];
               
 for i=1:length(bitdata)/4
     qam_data(i,:)=mapping(source(i),:);%����ӳ��
 end
 complex_qam_data=complex(qam_data(:,1),qam_data(:,2));
