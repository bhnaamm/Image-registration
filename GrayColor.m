
clc;
clear all;
close all;

%image registration;



unregistered = imread('westconcordaerial.png');% reads unregistered image

%if the image is full of noise use guassian filter to smooth it
%unregistered=imgaussfilt(unregistered)
%unregistered = imcrop(unregistered,[10,10,301,301]);
base = imread('westconcordorthophoto.png');% read refrence image
%if there is too much noise:
%base=imgaussfilt(base)
%base=imcrop(base,[15,15,301,301]);
%__________________________________________________________________________
rgb_1=double(unregistered);% changes image in ordet to use wavelet feature selection
[LLr(:,:,1),LHr(:,:,1),HLr(:,:,1),HHr(:,:,1)]=dwt2(rgb_1(:,:,1),'db1');
%[LLr(:,:,2),LHr(:,:,2),HLr(:,:,2),HHr(:,:,2)]=dwt2(rgb_1(:,:,2),'db1');%if
%rgb images are used omit comments 
%[LLr(:,:,3),LHr(:,:,3),HLr(:,:,3),HHr(:,:,3)]=dwt2(rgb_1(:,:,3),'db1');

wave_unregistered_1=uint8(LLr);% reads image result from wavelet transform

figure(7)
imshow(uint8(LLr))
title('LLr unregistered image')


%figure(8)
%imshow(uint8(LHr))
%title('LHr unregistered image')


%figure(9)
%imshow(uint8(HLr))
%title('HLr unregistered image')


%figure(10)
%imshow(uint8(HHr))
%title('HHr unregistered image')


%__________________________________________________________________________
%wavelet feature selection for base image
rgb_2=double(base);
 [LLr_2(:,:,1),LHr_2(:,:,1),HLr_2(:,:,1),HHr_2(:,:,1)]=dwt2(rgb_2(:,:,1),'db1');
%[LLr_2(:,:,2),LHr_2(:,:,2),HLr_2(:,:,2),HHr_2(:,:,2)]=dwt2(rgb_2(:,:,2),'db1');
%[LLr_2(:,:,3),LHr_2(:,:,3),HLr_2(:,:,3),HHr_2(:,:,3)]=dwt2(rgb_2(:,:,3),'db1');
wave_base_1=uint8(LLr_2);

figure;
imshow(uint8(LLr_2))
title('LLr base image')

figure;
imshow(uint8(LHr_2))
title('LHr base image')


figure;
imshow(uint8(HLr_2))
title('HLr base image')


figure;
imshow(uint8(HHr_2))
title('HHr base image')
%__________________________________________________________________________
%edge detection 
wave_unregistered=edge(wave_unregistered_1);
wave_base=edge(wave_base_1);
%__________________________________________________________________________
%control point selection tool(it is beter to choose  edge points )
%selects 5-10 control points from diffrent locations
cpselect(wave_unregistered,wave_base)


pause(70)%stops until variables come to the work space

%__________________________________________________________________________
%moves location of control points into original unregistered and based image

[a b c]=size(unregistered);
[a_1 b_1 c_1]=size(base);
[e f g]=size(wave_unregistered);
[e_1 f_1 g_1]=size(wave_base);

I_loc_orig_x = (movingPoints(:,1)*a)/e;
I_loc_orig_y = (movingPoints(:,2)*b)/f; 
unreg_orig = [I_loc_orig_x I_loc_orig_y];

I_I_loc_orig_x = (fixedPoints(:,1)*a_1)/e_1;
I_I_loc_orig_y = (fixedPoints(:,2)*b_1)/f_1;
base_orig = [I_I_loc_orig_x I_I_loc_orig_y];
    


%__________________________________________________________________________
mytform1 = cp2tform(unreg_orig,base_orig,...  %Infers spatial transformation from control point pairs
'nonreflective similarity');%Affine, also can be used here.


%__________________________________________________________________________
% Transforms the unregistered image
info = imfinfo('westconcordaerial.png');
registered = imtransform(unregistered,mytform1,...     %Applies 2-D spatial transformation to image
'XData',[1 info.Width], 'YData',[1 info.Height]);
%shows registered and based images together
figure, imshow(registered);
hold on
h = imshow(base);
set(h, 'AlphaData', 0.6)


figure;imshow(registered)


%__________________________________________________________________________
%PSNR&SNR
reg=rgb2gray(registered);
 new_registered = imresize(reg, [size(base,1), size(base,2)]);
% [peaksnr,snr] = psnr(new_registered,base);
%instead of using built-in functions,simply, we can calculate PSNR trough these 2
%lines of code
hfig = figure;
set(hfig,'Name','Please crop the image');
[new_registered, vec] = imcrop(new_registered);
base = imcrop(base,vec);

err = base - new_registered;
peaksnr = 10*log10(255/std(im2double(err(:))));
fprintf('\n The Peak-SNR value is %0.4f', peaksnr);
% fprintf('\n The SNR value is %0.4f \n', snr);
%__________________________________________________________________________
%match find
new_base = base;
AAAAA=new_base;
BBBBB=new_registered;
matches = AAAAA == BBBBB;
percentMatch_exact =100*sum(matches(:)) / numel(matches)
