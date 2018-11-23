function OFDM_BER_L(modu_type, SNR, comp)
x= cat(2,1,linspace(20,1000,50));
Ber_L=zeros(1,50);
temp=0;

if (~comp)
    for rounds=1:8
        for ii=1:50
            config=OFDMSettings(modu_type, SNR, ii*20, 0, 0, 0, 1,1024,8);
            baseband_out=OFDMSimpleSignalGenerator(config);
            Ber_L(ii)=Ber_L(ii)+OFDM(config,baseband_out);
        end
        config=OFDMSettings(modu_type, SNR, 1, 0, 0, 0, 1,1024,8);
        baseband_out=OFDMSimpleSignalGenerator(config);
        temp=temp+OFDM(config,baseband_out);
    end
    Ber_L=Ber_L./8;
    temp=temp/8;
    Ber_L=cat(2,temp,Ber_L);

    figure('Name','BER-L','NumberTitle','off');
    plot(x,Ber_L,'.r','MarkerSize',12);

    if (modu_type==1)
        title('BER-Number of Pathes  16-QAM  SNR=', num2str(SNR))
    else
        title('BER-Number of Pathes  QPSK  SNR=', num2str(SNR))
    end
    xlabel('Pathes')
    ylabel('BER')

    grid on
else
    for rounds=1:5
        for ii=1:50
            config=OFDMSettings(1, SNR, ii*20, 0, 0, 0, 1,1024,8);
            baseband_out=OFDMSimpleSignalGenerator(config);
            Ber_L(ii)=Ber_L(ii)+OFDM(config,baseband_out);
        end
        config=OFDMSettings(1, SNR, 1, 0, 0, 0, 1,1024,8);
        baseband_out=OFDMSimpleSignalGenerator(config);
        temp=temp+OFDM(config,baseband_out);
    end
    Ber_L=Ber_L./5;
    temp=temp/5;
    Ber_L=cat(2,temp,Ber_L);

    figure('Name','BER-L','NumberTitle','off');
    plot(x,Ber_L,'.r','MarkerSize',12);

    title(['BER-Number of Pathes  16-QAM/QPSK  SNR=', num2str(SNR)])
    xlabel('Pathes')
    ylabel('BER')
    grid on
    hold
    
    Ber_L=zeros(1,50);
    for rounds=1:5
        for ii=1:50
            config=OFDMSettings(0, SNR, ii*20, 0, 0, 0, 1,1024,8);
            baseband_out=OFDMSimpleSignalGenerator(config);
            Ber_L(ii)=Ber_L(ii)+OFDM(config,baseband_out);
        end
        config=OFDMSettings(0, SNR, 1, 0, 0, 0, 1,1024,8);
        baseband_out=OFDMSimpleSignalGenerator(config);
        temp=temp+OFDM(config,baseband_out);
    end
    Ber_L=Ber_L./5;
    temp=temp/5;
    Ber_L=cat(2,temp,Ber_L);

    plot(x,Ber_L,'*b','MarkerSize',4);
    legend('16-QAM','QPSK')
end