function OFDMTransferImage()
tImage=imread('Go.jpg');
tChunk=zeros(6,6,3,10000);

for i=0:99
    for j=0:99
        tChunk(:,:,:,100*i+1+j)=tImage((i)*6+1:(i+1)*6,(j)*6+1:(j+1)*6,:);
    end
end
chunkList=zeros(10000,1024)


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