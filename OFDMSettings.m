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
    config('bitsPerSymbol')=4;%ÿ���ź�������,16QAM����
else
    config('bitsPerSymbol')=2;%ÿ���ź�������,QPSK����
end
config('IFFTBinLength')= 2944;% length of IFFT
config('prefixRatio')=1/4;%���������OFDM���ݵı���
config('CPLength')=config('prefixRatio')*config('IFFTBinLength')
config('beta')=1/32;%����������ϵ��
config('CSLength')=config('beta')*(config('IFFTBinLength')+config('CPLength'));%ѭ����׺����
end