function [video_file] = LoadMitoData(v,path)
%LOADMITODATA Imports and processes the tiff video, and loads the Mitometer 
%data as a 2D matrix (trajectory number vs frame)
%   07.09.2023 Jessica Angulo Capel
%% Some parameters that we need first
load(path{2,v}); %loads the trackList variable from previously given path
pre_file{1,1} = trackList;

%% Video Import and Processing
% The following lines import the image from the given path
videoDataStore = datastore(path{1,v},'ReadFcn',@imfinfo);
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
n_traj = length(pre_file{1,1});
preview_file_x = NaN(n_traj,n_frames);
preview_file_y = NaN(n_traj,n_frames);
fission = NaN(n_traj,n_frames);
fusion = NaN(n_traj,n_frames);
asp_ratio = NaN(n_traj,n_frames);
for j = 1:n_traj
    c = 0;
    for k = 1:2:(length(trackList(j).frame))*2
        c = c + 1;
        f = trackList(j).frame(1,c);
        preview_file_x(j,f) = trackList(j).WeightedCentroid(1,k); %x value in px
        preview_file_y(j,f) = trackList(j).WeightedCentroid(1,k+1); %y value
        fission(j,f) = trackList(j).fission(1,c);
        fusion(j,f) = trackList(j).fusion(1,c);
        asp_ratio(j,f) = trackList(j).MajorAxisLength(1,c)/trackList(j).MinorAxisLength(1,c); %aspect ratio
    end
end
%% Save all important data
video_file{1,4} = preview_file_x;
video_file{1,5} = preview_file_y;
video_file{1,6} = fission;
video_file{1,7} = fusion;
video_file{1,8} = asp_ratio;
end