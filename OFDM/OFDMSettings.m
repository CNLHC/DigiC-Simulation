function config=OFDMSettings(using16QAM, SNR, L, plotEnable, SNR_test, CN, OP,carrierCount,SymbolsPerCarrier)
config=containers.Map;
config('SNR')=SNR;
config('L')=L;
config('plotEnable')=plotEnable;
config('SNR_test')=SNR_test;
config('CN')=CN;
config('OP')=OP;

config('Carriers')=carrierCount;
config('SymbolsPerCarrier')=SymbolsPerCarrier;
config('using16QAM')= using16QAM;
if (config('using16QAM')==1)
    config('BitsPerSymbol')=4;%ÿ���ź�������,16QAM����
else
    config('BitsPerSymbol')=2;%ÿ���ź�������,QPSK����
end
config('BasebandLength') = config('Carriers') * config('SymbolsPerCarrier') * config('BitsPerSymbol');%������ı�����Ŀ

config('IFFTLength')= 2944;% IFFT����
config('PrefixRatio')=1/4;%���������OFDM���ݵı���
config('CPLength')=config('PrefixRatio')*config('IFFTLength');
config('beta')=1/32;%����������ϵ��
config('CSLength')=config('beta')*(config('IFFTLength')+config('CPLength'));%ѭ����׺����

config('TrainingSymbolsLength')=4;%��Ƶ����
tmpTable = [-1,1,1i,-1i];%��Ƶ����Ϊ-1 1 -i i��ѡȡ���������
config('trainingSymbols') = (tmpTable(floor( 4*rand(config('TrainingSymbolsLength'),config('Carriers')))+1 ));%trainingSymbols_len*carrier_count����

end