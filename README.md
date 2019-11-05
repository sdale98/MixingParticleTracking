# MixingParticleTracking
Particle tracking code developed for 2019 Discovery Labs for year 3 Chemical Engineering at Imperial College London

Feed in video file in any format acceptable by MATLAB. Please note that framerate is rounded as certain inbuilt functions won't accept non-integer framerate values.

Will need to modify dimensioning parts of code for your system. Comments should walk you through this.

sd_streamlines function plots pathlines as quivers and is not called in main sd_finaltrack. If you wish to use this just add calls to main or use from command. Parameters in sd_MBMultiObjTrack will likely need varying for your system: experiment and compare output video data.

Median background video processing not likely to be needed if only moving objects in your video input are particles.

Important to ensure good spatial registration (especially in orientation: use spirit level or other tool) for this code to function correctly. Note there is no correction for distortion applied.

If you have any comments or improvements then please email me at sd1816@ic.ac.uk
