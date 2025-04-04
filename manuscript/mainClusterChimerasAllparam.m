function mainClusterChimerasAllparam(idx)

    %%%%% combination of different variables
    diffBroad = 18;%14:22;
    diffepsilon = 0:0.1:1;
    diffAlpha = 1.46;%1.4:0.02:1.56;
    diffProb  = [0 0.001 0.005 0.01 0.05 0.1];
    lag = pi/6;%[pi/12 pi/6 pi/2]; %-pi/12 -pi/6 -pi/2];
    [ca,cb,cc,cd, ce] = ndgrid(diffAlpha,diffBroad,diffProb,diffepsilon,lag);
    idxAlpha = ca(:);
    idxBroad = cb(:);
    idxProb = cc(:);
    idxEpsilon = cd(:);
    idxLag = ce(:);
    
    %%%% chimeras propierties
%     rng(idx);
    N=50;
    circw = 2*pi*1;

    fs=20;
    dt=0.05;
    per = [4:0.2:10 11:70]; %% periodicities 
    resets=20;
    contChim =0;
    allPeriodogram = nan(numel(per),resets);
    allZ = nan(100000,resets);
    rng(idx*ceil(second(datetime('now'))))
    %%%% generation of chimeras
    for re=1:resets
        [~,Z,outcome]=ChimerasSimAllParam(N,idxBroad(idx),idxAlpha(idx),0.01,idxEpsilon(idx),20000, rand(N,1)*2*pi,100,1000,dt,circw,idxLag(idx),idxProb(idx));
        allZ(:,re)=Z;
        if outcome==1
            Z = Z(20000:end);
    %             N=size(X,2);
            [~,~,Periodogram,~] = WaveletTransform(Z,fs,per);
            contChim=contChim+1;
            allPeriodogram(:,re)=Periodogram;
        end

    end
    name = append('/YOURPATH/',sprintf('PeriodoAlfa%0.2fBroad%0.0fEpsilon%0.1fProbRem%0.2fLag%0.3f.mat',idxAlpha(idx),idxBroad(idx),epsilon,idxProb(idx),idxLinks(idx)));
    save(name,'allPeriodogram','allZ','contChim','per');
end