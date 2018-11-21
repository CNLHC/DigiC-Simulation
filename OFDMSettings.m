function config=OFDMSettings(using16QAM, SNR, L, plotEnable, SNR_test, CN, OP)
config=containers.Map;
config('SNR')=SNR;
config('L')=L;
config('plotEnable')=plotEnable;
config('SNR_test')=SNR_test;
config('CN')=CN;
config('OP')=OP;
config('carrierCounts')=1024;
config('symbolsPerCarrier')=8;
config('using16QAM')= using16QAM;
if (config('using16QAM')==1)
    config('bitsPerSymbol')=4;%每符号含比特数,16QAM调制
else
    config('bitsPerSymbol')=2;%每符号含比特数,QPSK调制
end
config('IFFTBinLength')= 2944;% length of IFFT
config('prefixRatio')=1/4;%保护间隔与OFDM数据的比例
config('CPLength')=config('prefixRatio')*config('IFFTBinLength')
config('beta')=1/32;%窗函数滚降系数
config('CSLength')=config('beta')*(config('IFFTBinLength')+config('CPLength'));%循环后缀长度
end