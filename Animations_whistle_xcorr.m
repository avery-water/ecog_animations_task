clearvars;
close all;

indir='\\lc-rs-storage20.hpc.uiowa.edu\HBRL_Upload\for_Avery\Data\Animations\aligned\';
savedir='\\lc-rs-storage20.hpc.uiowa.edu\HBRL_Upload\for_Avery\Data\Animations\rawdata\from_Chris\EEG_data\extracted_data\';
blk='559-035';
%to run: 
%run on: '579-026', 559-035, 585-118, 603-028
%alignment off compared to computer recording: 567-091, 575-037, 593-031
[y1,fs1]=audioread([indir blk '_aligned.wav']);

S(1) = load('train');
y2=S.y;
fs2=S.Fs;

if fs1~=fs2
y2=resample(y2,fs1,fs2);
end

if strcmp(blk,'567-091')==1
y1(1:0.5*10^7)=y1(1:0.5*10^7).*0;
end

[c,lags]=xcorr(y1,y2); %Cross-correlation between two waveforms
cpos=c(find(lags==0):end); %Discard cross-correlogram for negative lags (i.e., start at lag=0);
lagspos=lags(find(lags==0):end); %Do the same for the lags vector

[pks,locs]=findpeaks(abs(cpos),lagspos,'MinPeakDistance',length(y2),'MinPeakHeight',max(abs(c))*0.70); 
%If visualization reveals that the peaks were not found correctly, change 0.9 to a different value

%Plot cross-correlogram
figure, 
plot(y1,'-k'); hold on; %Audio waveform
plot(lagspos,cpos./max(abs(c)),'-b'); %Cross-correlogram with the whistle waveform (positive lags only)
plot(locs,pks./max(abs(c)),'vr'); %Peaks (timestamps)

legend('Audio waveform','Cross-correlogram','Identified onsets');
%xlim([locs(1)-5000 locs(1)+5000]);

Evnt.timecorr=(locs./fs1)'; %Evnt.time contains ste timestamps (in seconds) of all trials (defined by onsets of whistle blows)

T=readtable('\\lc-rs-storage20.hpc.uiowa.edu\HBRL_Upload\for_Avery\Data\Animations\aligned_transcription.xlsx');
Evnt.evntcorr=T.video_code(T.subjid==str2double(blk(1:3)));
if strcmp('593-031',blk)==1
Evnt.evntcorr=Evnt.evntcorr(2:end);
end    
save([savedir blk '.mat'],'Evnt','-append');