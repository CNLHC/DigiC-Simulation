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
    config('BitsPerSymbol')=4;%每符号含比特数,16QAM调制
else
    config('BitsPerSymbol')=2;%每符号含比特数,QPSK调制
end
config('BasebandLength') = config('Carriers') * config('SymbolsPerCarrier') * config('BitsPerSymbol');%所输入的比特数目

config('IFFTLength')= 2944;% IFFT点数
config('PrefixRatio')=1/4;%保护间隔与OFDM数据的比例
config('CPLength')=config('PrefixRatio')*config('IFFTLength');
config('beta')=1/32;%窗函数滚降系数
config('CSLength')=config('beta')*(config('IFFTLength')+config('CPLength'));%循环后缀长度

config('TrainingSymbolsLength')=4;%导频长度
tmpTable = [-1,1,1i,-1i];%导频数据为-1 1 -i i中选取的随机序列
config('trainingSymbols') = (tmpTable(floor( 4*rand(config('TrainingSymbolsLength'),config('Carriers')))+1 ));%trainingSymbols_len*carrier_count矩阵

end