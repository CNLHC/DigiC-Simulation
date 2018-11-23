function [window]=Window(beta, Ts)
%�����Ҵ���betaΪ����ϵ����TsΪ����ѭ��ǰ׺��OFDM���ŵĳ���
window=zeros(1,(1+beta)*Ts);
t=0:(1+beta)*Ts;

for i=1:beta*Ts
	window(i)=0.5+0.5*cos(pi+ t(i)*pi/(beta*Ts));
end
window(beta*Ts+1:Ts)=1;
for j=Ts+1:(1+beta)*Ts+1
    window(j-1)=0.5+0.5*cos((t(j)-Ts)*pi/(beta*Ts));
end
window=window';%�任Ϊ������
