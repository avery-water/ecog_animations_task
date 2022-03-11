%Time-align Animations task laptop audio with Neuralynx (NLX) recordings

clearvars;
close all;

blk= '593-031';
%run on: 579-026, 559-035, 567-091, 575-037, 585-118, 593-031
%to run on:
%not run on: 603-028 as there was no computer audio, only NLX,Edit_save_603_audio.m script was used to process the audio
indir1='\\lc-rs-storage20.hpc.uiowa.edu\HBRL_Upload\for_Avery\Data\Animations\rawdata\from_Chris\EEG_data\extracted_data\'; %Location of the .mat file
indir2='\\lc-rs-storage20.hpc.uiowa.edu\HBRL_Upload\for_Avery\Data\Animations\rawdata\from_Dorit\audio_files\'; %Location of the laptop audio recording
savedir='\\lc-rs-storage20.hpc.uiowa.edu\HBRL_Upload\for_Avery\Data\Animations\aligned\'; %Location to save output

if strcmp(blk,'575-037')==1
    [y1,FS1]=audioread('\\lc-rs-storage20.hpc.uiowa.edu\HBRL_Upload\for_Avery\Data\Animations\aligned\575-037_NLX_denoised.wav');
else
    load([ indir1 blk '.mat'],'Inpt001'); %load the NLX audio
    y1=detrend(double(Inpt001.dat)); FS1=Inpt001.fs(1); %remove DC offset
end;

[y2,FS2]=audioread([indir2 blk(1:3) '.m4a']); %load the laptop-recorded audio

if FS2~=FS1
    y1=resample(y1,FS2,FS1); %resample NLX recording to match the (higher) sampling rate of the laptop recording
end

[c,lags]=xcorr(y2,y1); %Cross-correlation between two waveforms
figure, plot(lags,c); %Plot the cross-correlogram

if strcmp(blk,'575-037')==1
    midpoint=round(length(c)./2);
    [cmax, imax]=max(abs(c(midpoint:midpoint+1870000))); %Find the value of the peak of the cross-correlogram
    ylag=lags(imax)+midpoint; %Find the location (lag) of the peak of the cross-correlogram
else
    [cmax, imax]=max(abs(c)); %Find the value of the peak of the cross-correlogram
    ylag=lags(imax); %Find the location (lag) of the peak of the cross-correlogram
end
%xlim([148000 148100]); ylim([-3000 3000]);

if ylag>0 %if Laptop recording started earlier (this is the more common scenario)
    y2trim=y2(ylag:end); %Laptop recording with the initial portion (prior to NLX recording start) removed
    y2new=y1;
    y2new(1:length(y2trim))=y2trim; %populate from beginning to end with y2trim
    y2new=y2new(1:length(y1)); %remove the extra portion of the laptop recording (after NLX recorgins stopped);
else %if NLX started earlier
    disp('WARNING: Check NLX audio waveform y-range and adjust the normalization factor');
    pause
    y2new=y1./2000; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Specify normalization factor in the demonitator based on visual inspection of y1 waveform
    y2new((-ylag:length(y2)-ylag-1))=y2;
    y2new=y2new(1:length(y1)); %make sure it's the same length as y1 (trim end)
end
audiowrite([savedir blk '_aligned.wav'],y2new./max(abs(y2new)),FS2);