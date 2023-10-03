function [video_file] = LoadTrackmateData(i,path)
%LOADDATA Imports and processes the tiff video, and loads the Trackmate 
%data as a 2D matrix (trajectory number vs frame)
%   28.04.22 Jessica Angulo Capel
%% Import TrackMate data
trackDatastore = fileDatastore(path(2,i),'ReadFcn',@importTrackMate);
pre_file = readall(trackDatastore); %read out of the track file
pre_file{1,1} = sortrows(pre_file{1,1},'FRAME','ascend');
no_track = ~isnan(pre_file{1,1}.TRACK_ID);
pre_file{1,1} = pre_file{1,1}(no_track,:); %erase spots not assigned to any track

%% Video Import and Processing
% The following lines import the image from the given path
videoDataStore = datastore(path{1,i},'ReadFcn',@imfinfo);
video_file = readall(videoDataStore);
[image] = LoadTiffFast(video_file);
ch1 = image;
% Contrast enhancement and transfrmation to 8 bit
[~,~,n_frames] = size(ch1);
for i = 1:n_frames
    ch1(:,:,i) = imadjust(ch1(:,:,i));
end
ch1 = uint8(ch1/256);
%Saving channel 1
video_file{1,2} = ch1; %brings the whole matrix into the cell video_file
video_file = [pre_file,video_file];

%% Localizations data: used for the representation of the localization points, 
%trajetories, ID of the spots... 
a = video_file{1,2}(1).XResolution; %for scaling x
b = video_file{1,2}(1).YResolution; %for scaling y
[~,~,n_frames] = size(video_file{1,3});
traj_id = unique(video_file{1,1}.TRACK_ID);
preview_file_x = NaN(length(traj_id),n_frames);
preview_file_y = NaN(length(traj_id),n_frames);
temp_video = video_file{1,1}; %temporal video_file{1,1}
num_frame = zeros(1,n_frames);
for f = 1:n_frames
    while true
        track_frame = temp_video(temp_video.FRAME == f-1,:);
        temp_video(1:height(track_frame),:) = [];
        track_frame(isnan(track_frame.TRACK_ID) == 1,:) = []; %remove non tagged spots
        num_frame(1,f) = height(track_frame); %number of tracks per frame
        for t = 1:height(track_frame)
            track = table2array(track_frame(t,1));
            x_coord = track_frame.POSITION_X(track_frame.TRACK_ID == track);
            x_coord = ((x_coord*a)); %in px
            y_coord = track_frame.POSITION_Y(track_frame.TRACK_ID == track);
            y_coord = ((y_coord*b)); %in px
            preview_file_x(track+1,f) = x_coord;
            preview_file_y(track+1,f) = y_coord;
        end
        if height(temp_video) == 0
            break
        elseif temp_video.FRAME(1) ~= f-1
            break
        end
    end
end
video_file{1,4} = preview_file_x;
video_file{1,5} = preview_file_y;
end