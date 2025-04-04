function [P,Power,Periodogram,WTb] = WaveletTransform(ts,fs,per)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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


