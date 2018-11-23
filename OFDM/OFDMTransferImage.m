function OFDMTransferImage()
tImage=imread('Go.jpg');
tChunk=zeros(6,6,3,10000);

for i=0:99
    for j=0:99
        tChunk(:,:,:,100*i+1+j)=tImage((i)*6+1:(i+1)*6,(j)*6+1:(j+1)*6,:);
    end
end
symbolList=zeros(100,86400,'uint8');
for i=0:99
    bitstream=zeros(0,86400,'uint8');
    for j=0:99
        tC=de2bi(tChunk(:,:,:,100*i+1+j),8);
        tC=reshape(tC,1,864);
        bitstream(1,864*j+1:864*(j+1))= tC;
    end
    symbolList(i+1,:)=bitstream;
end

for i=0:99
    tBitStream=symbolList(i+1,:);
    for j=0:99
        tC=tBitStream(1,864*j+1:864*(j+1));
        
    
    



        
    
  


% tReImg=zeros(600,600,3,'uint8');
% for i=0:99
%     for j=0:99
%         tReImg((i*6)+1:(i+1)*6,(j*6)+1:(j+1)*6,:)=tChunk(:,:,:,100*i+1+j);
%     end
% end
% figure();
% imshow(tImage);
% figure();
% imshow(tReImg);






end