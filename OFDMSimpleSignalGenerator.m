function baseband_out=OFDMSimpleSignalGenerator(config)
baseband_out=round(rand(1,config('basebandOutLengthlength') ));%输出二进制比特流
end
