function [baseband_out,carriers]=OFDMSimpleSignalGenerator(config)
carriers = (1:config('carrierCounts'))+(floor(config('IFFTBinLength')/4) -floor(config('carrierCounts')/2));%����Գ����ز�ӳ�䣬ԭ�������ݶ�Ӧ����
baseband_out=round(rand(1,config('basebandOutLengthlength') ));%��������Ʊ�����
end
