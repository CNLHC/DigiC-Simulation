function [baseband_out,carriers]=OFDMSimpleSignalGenerator(config)
carriers = (1:config('carrierCounts'))+(floor(config('IFFTBinLength')/4) -floor(config('carrierCounts')/2));%共轭对称子载波映射，原复数数据对应坐标
baseband_out=round(rand(1,config('basebandOutLengthlength') ));%输出二进制比特流
end
