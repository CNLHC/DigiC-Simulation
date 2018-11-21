function [baseband_out,conjugate_carriers]=OFDMSimpleSignalGenerator(config)
baseband_out_length = config('carrierCounts') * config('symbolsPerCarrier') * config('bitsPerSymbol');%所输入的比特数目
carriers = (1:config('carrierCounts'))+(floor(config('IFFTBinLength')/4) -floor(config('carrierCounts')/2));%共轭对称子载波映射，原复数数据对应坐标
conjugate_carriers = config('IFFTBinLength') - carriers + 2;%共轭对称子载波映射，共轭复数对应的IFFT点坐标
baseband_out=round(rand(1,baseband_out_length));%输出二进制比特流
end
