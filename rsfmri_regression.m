function output_img=rsfmri_regression(input_img,regressors,brainmask)
output_img=zeros(size(input_img));
brain_index=find(brainmask>0);
[x,y,z]=ind2sub(size(brainmask),brain_index);
for n=1:length(brain_index)
     [~,~,r]=regress(squeeze(input_img(x(n),y(n),z(n),:)),regressors);
     output_img(x(n),y(n),z(n),:)=r;
end
end