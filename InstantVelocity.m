function [velocity_i] = InstantVelocity(video_file,pixel_size,dt)
%INSTANTVELOCITY calculates the frame to frame velocity in each track of
%video v. The velocity is defined as the euclidean distance [um] divided by time
%[s]. 
%   25.03.2022 Jessica Angulo Capel
v_x = video_file{1,4}.*pixel_size; %in nm
v_y = video_file{1,5}.*pixel_size; %in nm

%% Calculate velocities
[h,w] = size(v_x);
velocity_i = nan(h,w);
for j = 1:h %for each track
    if v_x(j,1) ~= 0 %if it is not a filtered track
        x = (v_x(j,:));
        y = (v_y(j,:));
        for k = 1:(length(x)-1)
            velocity = sqrt((x(1,k+1) - x(1,k)).^2 + (y(1,k+1) - y(1,k)).^2)/dt;
            velocity_i(j,k) = velocity;
        end
    end
end
end