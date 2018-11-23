function [window]=Window(beta, Ts)
%升余弦窗，beta为滚降系数，Ts为包含循环前缀的OFDM符号的长度
window=zeros(1,(1+beta)*Ts);
t=0:(1+beta)*Ts;

for i=1:beta*Ts
	window(i)=0.5+0.5*cos(pi+ t(i)*pi/(beta*Ts));
end
window(beta*Ts+1:Ts)=1;
for j=Ts+1:(1+beta)*Ts+1
    window(j-1)=0.5+0.5*cos((t(j)-Ts)*pi/(beta*Ts));
end
window=window';%变换为列向量
