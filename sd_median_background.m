function  [medfile] = sd_median_background(v, experimentname, notestframes, minsize)

%Production of a median background image from test frames of cropped video
%and production of a video of the image masked using thresholding above and
%below this median background image. Outputs are saved as videos instead of
%in workspace to prevent memory overflow. Modified heavily from 
%http://mbcoder.com/background-subtraction-in-matlab/. v is videoreader
%object input, minsize is minimum particle size in pixels

numframes = v.NumFrames; %measure no. frames
framerate = v.FrameRate; %measure framerate


   imgSet = cell(notestframes, 1); %prepopulate struct
   j=1; %second counter
   prog = waitbar(0, 'Loading Images for Averaging', 'Name', 'Progress');
    for k = 1:notestframes % Window size can be adjusted
        CurrentFrame = rgb2gray(read(v, k)); %loaded frame
       %Save to struct for learning:
        imgSet{k} = CurrentFrame;
          waitbar(k/notestframes);
    end
close(prog)

    dim = ndims(imgSet{1});          
    M = cat(dim+1,imgSet{:});        
    median_background = median(M,dim+1);
    Background = median_background;
    clear imgSet
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   prog = waitbar(0, 'Subtracting Background + Writing File', 'Name', 'Progress');
medfile = [experimentname, ' Median.avi'];
MaskVid = VideoWriter(medfile);
MaskVid.FrameRate = framerate;
open(MaskVid);
   
    for i =1:numframes
 
      CurrentFrame = rgb2gray(read(v, i)); %loaded frame
     
        FrameDiff = abs(double(CurrentFrame) - double(Background));
       
       Foreground = (FrameDiff > 50); % Tresholding, can be adjusted
        
Foreground = imcomplement(Foreground); %invert (BBs are black, need white for filling)
Foreground = bwareaopen(Foreground,minsize); %remove small white regions
Foreground = imcomplement(Foreground); %invert
Foreground = bwareaopen(Foreground,minsize); %remove small black regions
         CurrentFrame(~Foreground) = 255;
CurrentFrame = uint8(CurrentFrame); %Convert to image data

       writeVideo(MaskVid, CurrentFrame);
        waitbar(i/numframes);
    end
    close(prog)
    close(MaskVid)
end