function [rcosw]=rcoswindow(beta, Ts)
%���������Ҵ�������betaΪ����ϵ����TsΪ����ѭ��ǰ׺��OFDM���ŵĳ���,TsΪ��ż��

t=0:(1+beta)*Ts;
rcosw=zeros(1,(1+beta)*Ts);
for i=1:beta*Ts;
	rcosw(i)=0.5+0.5*cos(pi+ t(i)*pi/(beta*Ts));
end
rcosw(beta*Ts+1:Ts)=1;
for j=Ts+1:(1+beta)*Ts+1;
    rcosw(j-1)=0.5+0.5*cos((t(j)-Ts)*pi/(beta*Ts));
end
rcosw=rcosw';%�任Ϊ������
