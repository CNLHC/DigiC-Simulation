function OFDM_BER_SNR(modu_type, L, comp)
if (isnan(L)) 
    L=6;
end
    x= linspace(-5,25,61);
    Ber_SNR=zeros(1,61);
    CN=zeros(L,1);
    for i=1:L
    CN(i)=(randn(1)+1i*randn(1));
    end
if(~comp)
    for rounds=1:3
        for ii=1:61
            config=OFDMSettings(modu_type, (ii-11)/2, L, 0, 1, CN, 1,1024,8);
            Ber_SNR(ii)=OFDM(config);
        end
    end
    Ber_SNR=Ber_SNR./3;

    figure('Name','BER-SNR','NumberTitle','off');
    plot(x, Ber_SNR,'.b','MarkerSize',10,'MarkerEdgeColor','m');
    if (modu_type==1)
        title(['BER-SNR  L=',  num2str(L), '  16-QAM' ])
    else
        title(['BER-SNR  L=',  num2str(L), '  QPSK' ])
    end
    set(gca,'xtick',-5:5:25)
    xlabel('SNR/dB')
    ylabel('BER')
    grid on
else
    for rounds=1:2
        for ii=1:61
            config=OFDMSettings(1, (ii-11)/2, L, 0, 1, CN, 1,1024,8);
            Ber_SNR(ii)=OFDM(config);
        end
    end
    Ber_SNR=Ber_SNR./2;

    figure('Name','BER-SNR','NumberTitle','off');
    plot(x, Ber_SNR,'.r','MarkerSize',10,'MarkerEdgeColor','r');
    title(['BER-SNR  L=',  num2str(L), '  16-QAM/QPSK' ])
    set(gca,'xtick',-5:5:25)
    xlabel('SNR/dB')
    ylabel('BER')
    grid on
    hold
    
    for rounds=1:2
        for ii=1:61
            config=OFDMSettings(0, (ii-11)/2, L, 0, 1, CN, 1,1024,8);
            Ber_SNR(ii)=OFDM(config);
        end
    end
    Ber_SNR=Ber_SNR./2;
    plot(x, Ber_SNR,'*b','MarkerSize',4,'MarkerEdgeColor','b');
    legend('16-QAM','QPSK')
end
    