function output_img=rsfmri_bandpassfilt(input_img,TR,order,low_cutoff,high_cutoff,brainmask)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test code:
% load ampoutput1.mat
% Fs=1/TR;
% NFFT = length(y);
%[P,F] = periodogram(y,[],NFFT,Fs,'power');
% helperFrequencyAnalysisPlot2(F,10*log10(P),'Frequency in Hz','Power spectrum (dBW)',[],[],[-0.5 100])
% y=ratrsfmri_bandpassfilt(y,1/3600,4,20,80);
% [P,F] = periodogram(y,[],NFFT,Fs,'power');
% helperFrequencyAnalysisPlot2(F,10*log10(P),'Frequency in Hz','Power spectrum (dBW)',[],[],[-0.5 100])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NyqF=(1/TR)/2;
Wn=[low_cutoff high_cutoff]/NyqF;
[bfilter, afilter] = butter(order/2, Wn,'bandpass');
brain_index=find(brainmask>0);
input_img_2d=reshape(input_img,[],size(input_img,4));
output_img_2d = zeros(size(input_img_2d));
for n=1:length(brain_index)
    output_img_2d(brain_index(n),:)=filtfilt(bfilter, afilter, input_img_2d(brain_index(n),:));
end
output_img = reshape(output_img_2d,size(input_img,1),size(input_img,2),size(input_img,3),size(input_img,4));
end