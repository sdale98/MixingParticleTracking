# MixingParticleTracking
Particle tracking code developed for 2019 Discovery Labs for year 3 Chemical Engineering at Imperial College London.

Last update: 06/11/2019

Need MATLAB R2019B with computer vision toolbox installed. May work with earlier versions but not tested.

sd_finaltrack is main function. Reads in video file through GUI and allows cropping and trimming of video, writing a video file of this output to conserve memory. Also outputs dimensioning data for spatial registration: you need to modify dimensioning parts of code for your system as this was specific to our tank. Comments should walk you through this. Feed in video file in any format acceptable by MATLAB (avi, mp4 etc). Please note that framerate is rounded as certain inbuilt functions won't accept non-integer framerate values. Then main calls functions listed below:

sd_median_background called to median prethreshold and write prethresholded video from the cropped and trimmed video. Median background video processing not likely to be needed if only moving objects in your video input are particles (was used to reduce false positive detections due to impeller tip movement in this experiment).

For both raw cropped and median prethresholded video the following functions are called:

sd_MBMultiObjTrack was developed from a MATLAB tutorial for multiobject tracking (link in .m file). This uses vision.ForegroundDetector to isolate foreground, vision.BlobAnalyser to track centroid locations and then uses a constant velocity Kalman filter to maintain and predict particle tracks. Outputs cell array of particle locations etc., videos of particle boxes for the masked and unmasked video.

sd_dcentroids processes the locations of tracks in the video into arrays of centroid locations, dx and dy of these and pixel area of the detections (area was not used for output as was not found to be reliable. Perhaps using Kalman filter to predict area changes or tuning of the background selection methods could improve this).

sd_densitymapdim and sd_velmapdim produce dimensioned particle population and velocity distribution heatmaps respectively from the sd_dcentroids output.

Main saves all outputs to file for easier reprocessing.

sd_streamlines function plots pathlines as quivers and is not called in main sd_finaltrack. If you wish to use this just add calls to main or use from command. Parameters in sd_MBMultiObjTrack will likely need varying for your system: experiment and compare output video data.

Important to ensure good spatial registration (especially in orientation: use spirit level or other tool) for this code to function correctly. Note there is no correction for distortion applied: this is likely to be next major development of this code.

If you have any comments or improvements then please email me at sd1816@ic.ac.uk
