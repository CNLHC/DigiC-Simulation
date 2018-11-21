function [baseband_out,carriers]=OFDMSimpleSignalGenerator(config)
baseband_out_length = config('carrierCounts') * config('symbolsPerCarrier') * config('bitsPerSymbol');%������ı�����Ŀ
carriers = (1:config('carrierCounts'))+(floor(config('IFFTBinLength')/4) -floor(config('carrierCounts')/2));%����Գ����ز�ӳ�䣬ԭ�������ݶ�Ӧ����
baseband_out=round(rand(1,baseband_out_length));%��������Ʊ�����
end
