function Baseband=OFDMSimpleSignalGenerator(config)
Baseband=round(rand(1,config('BasebandLength') ));%输出二进制比特流
end
