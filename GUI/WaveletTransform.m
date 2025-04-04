function [P,Power,Periodogram,WTb] = WaveletTransform(ts,fs,per)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS:
% - h: timestamps in hours
% - ts: timeseries sampled hourly (fs = 24h per day), with NaNs replacing gaps. 
% - optional band pass with 2-3 rows of  high-pass and low pass setting in period (days) for filtered
% ts, e.g. hp = 1 and lp = 7 will filter for periods of 1 to 7 days
% - Note: the functions pads the timeseries by reflecting data on both extremities and crops the padding before returning power.
% the timeseries has to be 2 months long at least to apply padding on both sides
% - per: periods to evaluate
% - transitions: settings changes 

% OUTPUTS
% - P: power
% - Phi: phase
% - per: vector of periods used
% - filt_ts: matrix where each row reprsent filtered signal in bandpass
% define in corresponding row of bp
% - per_max: peak of power in bands defined in bp
% - WT: wavelet transform, complex numbers

% CHANGE log
% - 11/23:  entered all inputs explicitly, no need to globalize any variable
%           [P,Phi,per, filt_ts, per_max, spct] = NP_wt3(ts,wav,bp)
% - 11/26:  moved get peaks to a separate function
%           11/26: [P,Phi,per, filt_ts, per_max, spct] = NP_wt4(h,ts,wav,bp,per,transitions)
% - June 2018: normalization done outside of this function. 
% - Oct 2018:  
%           - take into account periodicities up to 3 months
%           - cross gaps that can be crossed for longer periodicities,
%           then mask with COI
%           - calculate number of cycles for each period
%           - discarded wavelet family option, as always using morlet
% 
% TO DOs
% - ideally extrapolate one cycle into gap
% - ideally should fill in circadian rhythm with average
% - see if dc component is needed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameters
ts=ts(:)';
t =length(ts);                                                               % 24h/day, so period units will therefore be days
fourier_factor = 1.0330;
scales = per/fourier_factor;                                            % period = fourier_factor*scale;
dt = 1/fs;                                                              % fs = 24 h/d Hz -> sampling period dt = 1/24 day;
ts(isnan(ts))=0;
% WAVELET TRANSFORM
in=1;
fin=numel(ts);
cont=0;

cont=cont+1;
block = ts(in:fin);
WT = cwtft({block,dt},'scales',scales,'wavelet','morl');            % Morlet wavelet
Power=abs(WT.cfs);
WTb=WT.cfs;

% REMOVE CONE OF INFLUENCE
for p = 1:numel(per)
    fullp = per(p)*fs;                                                  % full period
    partp = fullp*0.2;                                                  % fraction (20%) of each period that can be interpolated
    coi=ceil(fullp*fourier_factor);
     Power(p,1:1+coi) = NaN;                                % beginning                          % beginning
     Power(p,end-coi:end) = NaN;
     WTb(p,1:1+coi) = NaN;                                % beginning                          % beginning
     WTb(p,end-coi:end) = NaN; 
end
P(:,cont) = nanmean(Power,2);                              % POWER square root absolute power



Periodogram=nanmean(P,2);


end


