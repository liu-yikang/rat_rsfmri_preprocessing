function output_img=rsfmri_smooth(input_img,FWHM,voxelsize)
sigma=FWHM/(2*sqrt(2*log(2))*voxelsize);
[~, ~, ImgZ, T] = size(input_img);
output_img=zeros(size(input_img));
for t = 1:T
    for z = 1:ImgZ
        output_img(:,:,z,t) = imgaussfilt(input_img(:,:,z,t), sigma,'FilterDomain','spatial');
    end
end
end