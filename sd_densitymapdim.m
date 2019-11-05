function [densmap, wx, wy, N] = sd_densitymapdim(dcentroids, testname, cropsz, gridincr, metrel, y0m)
%Creation of density (population!) map averaged over region from dcentroids matrices

%Gridincr: grid spacing in cm

gridincrm = gridincr/100; %grid increment in m
gridincrpix = round(gridincrm*metrel); %convert grid increment to pixels, round to nearest pixel

ldcent = length(dcentroids);

plotname = [testname, ' Population Map'];

xdivs = floor(cropsz(2)/gridincrpix); ydivs = floor(cropsz(1)/gridincrpix); %Exclusion of partial regions for plotting
xl = xdivs*gridincrpix; yl = ydivs*gridincrpix;

X = []; %initialise cell array for filling with density data
Xpos = 1;%initialise X position counter
for i = 1:ldcent
    fr = dcentroids{i, 1};
    lfr =size(fr);
    lfr= lfr(1);
    for j = 1:lfr
          x = round(fr(j, 2)); y = round(fr(j, 3));
          
          if (x>0) && (y>0) && (x<=xl) &&  (y<=yl)
              X{Xpos, 1} = x; X{Xpos, 2} = y; %fill X with particle locations falling within frame 
              %(predicted locations of lost tracks will leave frame)
              Xpos = Xpos+1;
          end
          
    end  
        
end

X = cell2mat(X);

[N, C] = hist3(X, 'edges', {0:gridincrpix:xl, 0:gridincrpix:yl}); %output histogram data

 N = N/max(N, [], 'all');
 N = flip(N, 2); %flip as image origins are top left (issue with way MATLAB defines image coords)
N = N';
 

wx= 100*(C{1}(:)-(gridincrpix/2))/metrel;
wy= 100*(((C{2}(:)-(gridincrpix/2))/metrel)+y0m); %Alignment of centroids to physical coordinates (no need to 
%flip these as are evenly spaced in any case)
% display
densmap = figure('Name', ([plotname, ' Dimensioned']), 'NumberTitle', 'off');
H = pcolor(wx, wy, N); %pseudocolour plotting
box on
shading interp %change to comment if don't wish to interpolate
set(H,'edgecolor','none');
c = colorbar;
colormap hot;
set(gca,'Layer','top')
set(gca,'fontsize',24, 'linewidth',3, 'TickLabelInterpreter','latex', 'YColor','k')
c.LineWidth = 3;
c.Label.String = 'Particle Density';
c.Label.Interpreter = 'latex';
c.TickLabelInterpreter = 'latex';
title(plotname,'interpret', 'latex', 'fontsize',24)
xlabel('$$\mbox{x location, } cm$$','interpret', 'latex', 'fontsize',24)
ylabel('$$\mbox{y location, } cm$$','interpret', 'latex', 'fontsize',24)
savefig([plotname, ' Dimensioned']);

end