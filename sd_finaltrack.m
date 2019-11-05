%Alternative approach to particle tracking
%close all, clear all %ensures only selected variables are saved
%% Video Import
[vfile,vpath] = uigetfile('*.*', 'Select video file', 'C:\Users');
if isequal(vfile,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(vpath,vfile)]);
end
cd(vpath)
v = VideoReader(vfile); %the video to read
get(v) %show image data
prompt = {'Enter dataset name', 'Enter start time (s)','Enter end time (s)'};
dlgtitle = 'Input Data';
inputdat = inputdlg(prompt,dlgtitle,[1 40]);
experimentname = inputdat{1}; stend = inputdat(2:3); %pull out name, start end data
stend=str2double(stend); %convert to double
timestart = stend(1); %choose time to start data analysis
timeend = stend(2); %choose time to end data analysis (select before video ends)
df=1; %choose the gap between frames (the smaller the longer it will take to run)
framerate= round(v.FrameRate);
numframes = (timeend-timestart)*framerate; %no frames for test
framestart = framerate*timestart; %start frame
frameend = framerate*timeend; %end frame

v.CurrentTime = timestart; %% select start time
frame = (readFrame(v));

%% Measure Length Scale + Position Indicators
thr =1;
%Horizontal
while thr == 1
dimfigx = figure('Name','Select Horizontal Line Along Surface','NumberTitle','off');
xdimcheck = imshow(frame);
xdiml = drawline;
xpos = xdiml.Position;
xchoice = questdlg('Use this selection?','x Line Setting',...
                  'Yes','No','Yes');
              switch xchoice
              case 'No'
                      thr = 1;
                      close(dimfigx);
               case 'Yes'
                   thr = 0;
                   close(dimfigx);
             end
end

%So xpos allows dimensioning of coord system + finding surface
%Location of top by averaging y positions of ends of xline
toploc = mean2(xpos(:, 2)); 

%% Select Crop Area + Define Dimensioned Coordinates

fi = figure('Name','Crop Selection','NumberTitle','off');
              hold on
              

 imcheck1 = imshow(frame);
  [~, crop] = imcrop(imcheck1);
                      crop = round(crop);
                      
                      %Note: in code used this was modified to reoutput
                      %crop with constant aspect ratio (file lost, simply
                      %reoutput crop box using specified aspect ratio as
                      %workaround)
                      
                        [frameCrop, crop] = imcrop(frame, crop); %recrop with integer crop
                      cropsz = size(frameCrop); %measure crop
                      
                      pixels_185 = cropsz(2); %use crop width to measure outer d of tank. Modify for your experiment
                      metrel = pixels_185*1/0.185; %Pixels/m
                      
                      
%find co-ords of all four corner points
topleft = [crop(1), crop(2)];
topright = [crop(1) + crop(3), crop(2)];
bottomleft = [crop(1), crop(2) + crop(4)];
bottomright = [crop(1) + crop(3), crop(2) + crop(4)];

%Distance between surface and top of crop box (used for dimensioning later)

ltop =abs((toploc - crop(1))/metrel);

%Distance between surface and bottom of crop box:
lbottom = abs((toploc-(crop(2)+crop(4)))/metrel);

%Start of y axis in m for plots

y0m = 0.175-lbottom; % Start of y is designated as distance between bottom of crop and
%bottom of fluid

%Surface line
surfaceline1 = [0, toploc]; surfaceline2 = [v.Width, toploc];
line([surfaceline1(1), surfaceline2(1)], [surfaceline1(2), surfaceline2(2)],...
    'Color','red','LineWidth',2);

%draw the rectangle
line([topleft(1) topright(1)],[topleft(2) topright(2)],'Color','red','LineWidth',2);
line([topleft(1) bottomleft(1)],[topleft(2) bottomleft(2)],'Color','red','LineWidth',2);
line([topright(1) bottomright(1)],[topright(2) bottomright(2)],'Color','red','LineWidth',2);
line([bottomleft(1) bottomright(1)],[bottomleft(2) bottomright(2)],'Color','red','LineWidth',2);

%% Cropping example image

%startCrop = imcrop(readFrame(v), crop);
%imshow(startCrop);

%% Creation of cropped video for video writing (workaround for matlab computer vision toolbox)
%Can only specify training frames from start of video - hence output
%cropped + trimmed video
datadirname = [experimentname, ' Processed Outputs'];
croppedvidname = [experimentname, ' Cropped.avi'];
mkdir (datadirname); %new folder for saving data
cd (datadirname);
vcrop = VideoWriter(croppedvidname);
prog = waitbar(0, 'Writing Cropped + Trimmed Video', 'Name', 'Progress');
vcrop.FrameRate = framerate;
open(vcrop);
for fr = framestart:(framestart+numframes)
    frload = imcrop(read(v, fr), crop);
    writeVideo(vcrop, frload);
    waitbar(fr/(framestart+numframes));
end
close(vcrop);
close(prog);
clear v; %costly to hold in memory

%% Calling of function for median background preprocessing
vcroprd = VideoReader(croppedvidname);
[medfile] = sd_median_background(vcroprd, experimentname, 180, 600);
clear vcroprd;

%% Calling of multiple object tracking function for raw file
minarea = 500; %min detected particle size setting
testnameraw = [experimentname, ' Raw'];
[tracksraw] = sd_MBMultiObjTrack(croppedvidname, framerate, numframes, testnameraw, minarea);

%% Difference in centroid location frame to frame

[dcentraw] = sd_dcentroids(tracksraw, framerate);

%% Particle density plot
gridincr = 1;


[densmapdimraw, wxrawdim, wyrawdim, Nrawdim] = sd_densitymapdim(dcentraw, testnameraw,...
    cropsz, gridincr, metrel, y0m);


%% Velocity plot

 [velmapdimraw, wxrawdimv, wyrawdimv,  magavrawdim] = sd_velmapdim(dcentraw, testnameraw, ...
     cropsz, gridincr, metrel, y0m);

%% Calling of multiple object tracking function for median thresholded file

testnamemed = [experimentname, ' Med'];
[tracksmed] = sd_MBMultiObjTrack(medfile, framerate, numframes, testnamemed, minarea);

%% Difference in centroid location frame to frame

[dcentmed] = sd_dcentroids(tracksmed, framerate);


%% Density plot

[densmapdimmed, wxmeddim, wymeddim, Nmeddim] = sd_densitymapdim(dcentmed, testnamemed, ...
    cropsz, gridincr, metrel, y0m);


%% Velocity plot

[velmapdimmed, wxmeddimv, wymeddimv,  magavmeddim] = sd_velmapdim(dcentmed,...
    testnamemed, cropsz, gridincr, metrel, y0m);

save(experimentname); %output all variables to workspace for easier reprocessing if mistake made + output to streamline function if desired