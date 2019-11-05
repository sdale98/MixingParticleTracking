function [streamfig, tracksdif] = sd_streamlines(dcentroids, testname, cropsz, testlength, metrel, y0m)
%Plotting of pathline quiver plot for particle velocity vectors.
%Methodology could be improved but limited usefulness for 2D datasets.

%ldcentroids = length(dcentroids); %measure length 
tracks = cell(1, 1); %empty array of particle tracks
tracksloc = 1; %initialise counter for track numbers

streamfig = figure('Name', [testname, ' Pathlines: Quiver Plot'], 'NumberTitle', 'off');
set(gca,'fontsize',24, 'linewidth',3, 'TickLabelInterpreter','latex', 'YColor','k')

title([testname, ' Pathlines: Quiver Plot (', num2str(testlength), ' frames)'],'interpret', 'latex', 'fontsize',24)
xlabel('$$\mbox{x location, } cm$$','interpret', 'latex', 'fontsize',24)
ylabel('$$\mbox{y location, } cm$$','interpret', 'latex', 'fontsize',24)

%set(l,'fontsize',24,'Interpreter','latex', 'location', 'bestoutside')
daspect([1 1 1]);

hold on

for idno = 1:1000 %set max to max id found in dcentroids (easily implementable)
    strmat = zeros(1, 2); %empty matrix for particle locations
    strmatloc = 1; %reinitialise strmat location counter for each id
     for frameno = 1:(testlength-1)
    dfmat1 = dcentroids{frameno, 1}; %load frame 1
    dfmat2 = dcentroids{(frameno+1), 1}; %load next frame
     isid1 = any(dfmat1(:, 1) == idno, 2) ; %check if particle is present in frame 1
      isid2 = any(dfmat2(:, 1) ==idno, 2); %find id in matrices if exists
          rowno1 = find(isid1);
          rowno2 = find(isid2); %find locations
          
             if (isempty(rowno1) == 0) && (isempty(rowno2)==0) %check if present in both
                 xmid = dfmat1(rowno1, 2);  ymid = dfmat1(rowno1, 3);  %find x and y locs in 1st frame
                 strmat(strmatloc, 1) = xmid; strmat(strmatloc, 2) = ymid; %fill in x and y locations in stream matrix
                 strmatloc = strmatloc+1;
             elseif  (isempty(rowno1) == 0) && (isempty(rowno2)==1) %check if present in only frame 1
                 xend = dfmat1(rowno1, 2);  yend = dfmat1(rowno1, 3);  %output final part of streamline points
                 strmat(strmatloc, 1) = xend; strmat(strmatloc, 2) = yend; %fill in final x and y locations of stream matrix
                 %scatter(strmat(:, 1), strmat(:, 2)); %plot streams
                tracks{tracksloc, 1} = strmat; %populate output tracks matrix
                tracksloc = tracksloc+1; %advance track counter
                strmat = zeros(1, 2); % new empty matrix for particle locations
                strmatloc = 1; %reinitialise strmat location counter;
             
             end
                 
     end
             
end
       
sd_quiverplot;
legend({'Velocity Vectors (scaled)'}, 'location', 'southeastoutside', 'fontsize', 24, 'interpreter', 'latex');

    function sd_quiverplot
        ltracks = length(tracks);
        tracksdif = zeros(100000, 4);
        
tracksdifloc = 1;
       for k = 1:ltracks
           trackdata = tracks{k, 1};
           trackdata(:, 2) = cropsz(1) - trackdata(:, 2); %Flip y data: image flipped in y
           trackdata(:, 1) = trackdata(:, 1)/metrel;
           trackdata(:, 2) = trackdata(:, 2)/metrel + y0m;
           
           ltrackdat = length(trackdata);
           for l = 2:ltrackdat
              trackdata(l, 3:4) =  trackdata(l, 1:2) - trackdata((l-1), 1:2); %adding dx, dy to 4th column
           end
                trackdata(1, :) = [];
                trackdata = 100*trackdata;
       tracksdif(tracksdifloc:(tracksdifloc + ltrackdat-2), 1:4) = trackdata;
       tracksdifloc = tracksdifloc + ltrackdat-1;
       %quiver(trackdata(:, 1), trackdata (:, 2), trackdata(:, 3), trackdata(:, 4))
       end
        tracksdif = tracksdif(all(tracksdif, 2), :);
        quiver(tracksdif(:, 1), tracksdif (:, 2), tracksdif(:, 3), tracksdif(:, 4), 2)
  xlim ([0, 100*(cropsz(2)/metrel)]);
ylim([100*y0m, 100*(cropsz(1)/metrel+y0m)]); 
    end
end 
    


