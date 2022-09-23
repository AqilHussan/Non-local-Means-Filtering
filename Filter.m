close all;
Image = imread("krishna_0_001.png");             %%Image Read
figure('Name','Orginal Image');
imshow(Image);                              %%Display input image
Ref = imread("krishna.png");
%Applying NLM filter with W = 3, Wsim = 3
Wsearch=3;
Wsim=3;
h=.1:.1:.5;
for i=1:5
filtered=NLM(Image,Wsearch,Wsim,h(i));
%Finding psnr values
peaksnrNLM3(i)=10*log10(255*255 / immse(uint8(filtered),Ref));
end
%plotting
figure('Name','PSNR plot');
hold on;
plot(h,peaksnrNLM3, 'Color', 'r');
%Applying NLM filter with W = 5, Wsim = 3
Wsearch=5;
Wsim=3;
h=.1:.1:.5;
for i=1:5
filtered=NLM(Image,Wsearch,Wsim,h(i));
%Finding psnr values
peaksnrNLM5(i)=10*log10(255*255 / immse(uint8(filtered),Ref));
end
%Plotting
plot(h,peaksnrNLM5, 'Color', 'g');
hold off;
figure('Name','PSNR plot2');
hold on;
plot(h,peaksnrNLM3, 'Color', 'r');
plot(h,peaksnrNLM5, 'Color', 'r');

%%%Applying gaussian filter %%%%%%
SD=.1:.1:.5;  %%Initializing Standard Deviation
for i=1:5
gaussian=GaussianKernal(SD(i),3);                %%Find Gaussian kernal
ImgOut(:,:,1)=Convolution2D(Image(:,:,1),gaussian);       %%Convolving
ImgOut(:,:,2)=Convolution2D(Image(:,:,2),gaussian);       %%Convolving
ImgOut(:,:,3)=Convolution2D(Image(:,:,3),gaussian);       %%Convolving
%Finding the psnr
peaksnr(i)=10*log10(255*255 / immse(uint8(ImgOut),Ref));
end
%plotting
plot(SD,peaksnr, 'Color', 'b');
hold off;

Wsearch=5;
Wsim=3;
h=.5;
NLMfiltered=NLM(Image,Wsearch,Wsim,h);
SD=1;
gaussian=GaussianKernal(SD,5);                %%Find Gaussian kernal
ImgGOut(:,:,1)=Convolution2D(Image(:,:,1),gaussian);       %%Convolving
ImgGOut(:,:,2)=Convolution2D(Image(:,:,2),gaussian);       %%Convolving
ImgGOut(:,:,3)=Convolution2D(Image(:,:,3),gaussian);       %%Convolving
figure('Name','11*11 kernal');
imshow(gaussian);

patchNoisy1=findpatch(Image,31,46);
figure('Name','PatchNoisy 31,46');
imshow(patchNoisy1);

patchNoisy2=findpatch(Image,38,58);
figure('Name','PatchNoisy 38,58');
imshow(patchNoisy2);
patchNoisy3=findpatch(Image,31,58);
figure('Name','PatchNoisy 31,58');
imshow(patchNoisy3);
patchNoisy4=findpatch(Image,38,46);
figure('Name','PatchNoisy 38,46');
imshow(patchNoisy4);
patch1=findpatch(NLMfiltered,31,46);
figure('Name','Patch NLM 31,46');
imshow(patch1);
patch2=findpatch(NLMfiltered,38,58);
figure('Name','Patch NLM 38,58');
imshow(patch2);
patch3=findpatch(NLMfiltered,31,58);
figure('Name','Patch NLM 31,58');
imshow(patch3);
patch4=findpatch(NLMfiltered,38,46);
figure('Name','Patch NLM 38,46');
imshow(patch4);
patch1G=findpatch(ImgGOut,31,46);
figure('Name','Patch Gaussian 31,46');
imshow(patch1G);
patch2G=findpatch(ImgGOut,38,58);
figure('Name','Patch Gaussian 38,58');
imshow(patch2G);
patch3G=findpatch(ImgGOut,31,58);
figure('Name','Patch Gaussian 31,58');
imshow(patch3G);
patch4G=findpatch(ImgGOut,38,46);
figure('Name','Patch Gaussian 38,46');
imwrite(patch4G,'PG3846.jpg');


%Fuction to take 11*11 patch
function patch=findpatch(image,rows,cols)
patch=uint8(image(rows-5:rows+5,cols-5:cols+5,:));

end
%Function to perform NLM filtering
function filtered=NLM(Image,Wsearch,Wsim,h)
[row,col,d]=size(Image);%finding the size of the image
PaddedInput=padarray(Image,[Wsim Wsim],0,'both'); %Zero padding the image
filtered=zeros(row,col,d);%initializing the filtered output
%Traversing through each pixel
for i=1:row
 for j=1:col
         %Finding the actual image pixel cordinates
         i1 = i+ Wsim;
         j1 = j+ Wsim;
         %Finding NP       
         Np= PaddedInput(i1-Wsim:i1+Wsim , j1-Wsim:j1+Wsim);
         %Finding the upper and lower bound for the patch
         WindowRmin = max(i1-Wsearch,Wsim+1);
         WindowRmax = min(i1+Wsearch,row+Wsim);
         WindowCmin = max(j1-Wsearch,Wsim+1);
         WindowCmax = min(j1+Wsearch,col+Wsim);
         Z=0;%Initializing the sum of weight
         for u=WindowRmin:1:WindowRmax
         for v=WindowCmin:1:WindowCmax    
                %Finding Nq
                Nq= PaddedInput(u-Wsim:u+Wsim , v-Wsim:v+Wsim); 
                %Finding G
                X = sum((Np-Nq).^2,'all');                    
                G=exp(-X./(h*h)); 
                %Adding the weights
                Z=Z+G;
                filtered(i,j,:)=filtered(i,j,:)+double(G).*double(PaddedInput(i1,j1,:));
                
                 
                
         end
         end
         filtered(i,j,:)=filtered(i,j,:)/Z;
 end
end
end
                
         