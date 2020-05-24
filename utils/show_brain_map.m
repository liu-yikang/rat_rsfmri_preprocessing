function show_brain_map(map,map_wholefov,min,max,cluster_size,selected_slices,option)

ana=spm_read_vols(spm_vol(which('standard_anatomy_t2.nii')));
ana = ana(:,:,selected_slices);
ana = imresize(ana,0.25);
brain_mask=spm_read_vols(spm_vol(which('brain_mask_64x64.nii')));
wm_csf_mask = spm_read_vols(spm_vol(which('WM_CSF_mask_64x64.nii')));
brain_mask = brain_mask(:,:,selected_slices);
wm_csf_mask = wm_csf_mask(:,:,selected_slices)>0;

if isempty(map_wholefov)
map3d = zeros(size(ana))*nan;
map3d(brain_mask>0) = map(:);
map = map3d;
% map(wm_csf_mask) = nan;
else
    map = reshape(map_wholefov,64,64,[]);
end

ana = ana(15:50,64:-1:32,:);

for i_slice = 1:size(ana,3)
    x = ceil(i_slice/4);
    y = rem(i_slice,4);
    if y==0
        y=4;
    end
    ana_flat(33*(x-1)+1:33*x,36*(y-1)+1:36*y) = ana(:,:,i_slice)';
end

map = map(15:50,64:-1:32,:);
for i = 1:size(map,3)
    x = ceil(i/4);
    y = rem(i,4);
    if y==0
        y=4;
    end
    map_flat(33*(x-1)+1:33*x,36*(y-1)+1:36*y) = map(:,:,i)';
end
map_flat(:,1:end-1,:) = map_flat(:,2:end,:);
if option == 1 % symmetric color range
    mask = abs(map_flat)>min;
    mask = bwareaopen(mask,cluster_size,8);
    map_flat(~mask) = nan;
    
    h = figure;
    h.Position = [0,0,800,800];
    rat_fmri_imoverlay(ana_flat,map_flat,...
        [-max max],[0,5800],'jet',0.8,h);
    colormap('jet');
else
    mask = map_flat>min;
    mask = bwareaopen(mask,cluster_size,8);
    map_flat(~mask) = nan;
    
    h = figure;
    h.Position = [0,0,800,800];
    rat_fmri_imoverlay(ana_flat,map_flat,...
        [min max],[0,5800],'jet',0.8,h);
    colormap('jet');
end

bregmas = -10.2:1:4.8;

%text(5,36,['Bregma ',num2str(-10.2),' mm'],'FontSize',12,'FontWeight','bold','Color','w');

ys = 12 + (1:36:110);
xs = 35 + (1:33:100);
xs(end) = 128;


for i = 1:length(bregmas)
    x = floor((i-1)/4)+1;
    y = rem(i,4);
    if y == 0
        y = 4;
    end
    text(ys(y),xs(x),[num2str(bregmas(i)),' mm'],'FontSize',12,'FontWeight','bold','Color','w');
end

end