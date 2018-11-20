function [complex_qam_data]=qam16(bitdata)
%16QAM调制
X1=reshape(bitdata,4,length(bitdata)/4)';
d=1;%星座图坐标单位长度 
for i=1:length(bitdata)/4
    for j=1:4
        X1(i,j)=X1(i,j)*(2^(4-j));
    end
        source(i,1)=1+sum(X1(i,:));%四比特码元映射至1~16
end
mapping=[   d,d;         d,3*d;        d,-d;       d,-3*d;
                    3*d,d;     3*d,3*d;     3*d,-d;    3*d,-3*d;
 	                -d,d;       -d,3*d;        -d,-d;       -d,-3*d;
	               -3*d,d;   -3*d,3*d;    -3*d,-d;    -3*d,-3*d];
               
 for i=1:length(bitdata)/4
     qam_data(i,:)=mapping(source(i),:);%数据映射
 end
 complex_qam_data=complex(qam_data(:,1),qam_data(:,2));
