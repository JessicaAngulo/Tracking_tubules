    function [Dif_i] = MSD(video_file,pixel_size,dt)
%Calculation of the Mean Squared Displacement. 
%The immediate diffusion coefficient (D) is the slope of the equation
%MSD = 2dDm, assuming a Browinan motion. 
%   16.06.2021 Jessica Angulo Capel
v_x = (video_file{1,4}.*pixel_size); %in nm
v_y = (video_file{1,5}.*pixel_size);
[h,w] = size(v_y);

%% Calculate msd for each m, and fit the D(1-4)
msd_i = nan(h,w); %rows will be each track, and columns will be m
Dif_i = nan(h,1);
for j = 1:h %for each track
    if v_x(j,1) ~= 0 %previously filtered track
        x = (v_x(j,:))';
        x = x(~isnan(x),1);
        y = (v_y(j,:))';
        y = y(~isnan(y),1);
        N = length(x);
        for m = 0:N-1
            msd = sum(((x(1+m:end) - x(1:end-m)).^2)+(y(1+m:end) - y(1:end-m)).^2,'omitnan')/(N-m);
            msd_i(j,m+1)= msd;
        end
        if N > 12
            msd_j = msd_i(j,1:4);
            D = polyfit((4*(1:4)*dt),msd_j,1); %instant diffusion, calculated for t lag from 1 to 4.
            D = D(1,1);
            if D > 0
                Dif_i(j,1) = D;
            end
        end
    end
end