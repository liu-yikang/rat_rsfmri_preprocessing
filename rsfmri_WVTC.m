function wvtc=rsfmri_WVTC(input_img,WM_CSF_mask)
WM_CSF_index= WM_CSF_mask>0;
img=reshape(input_img,[],size(input_img,4));
temp=img(WM_CSF_index,:);
tc_mean=mean(temp,2);
temp(tc_mean<500,:)=[];
wvtc=mean(temp);
end