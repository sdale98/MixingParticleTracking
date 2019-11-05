function [velmap, wx, wy, gridmagav] = sd_velmapdim(dcentroids, testname, cropsz, gridincr, metrel, y0m)
%Creation of velocity map averaged over region from dcentroids matrices
ldcent = length(dcentroids);

%Gridincr: grid spacing in cm

gridincrm = gridincr/100; %grid increment in m
gridincrpix = round(gridincrm*metrel); %convert grid increment to pixels, round to nearest pixel


plotname = [testname, ' Velocity Map'];

xdivs = floor(cropsz(2)/gridincrpix); ydivs = floor(cropsz(1)/gridincrpix);
xl = xdivs*gridincrpix; yl = ydivs*gridincrpix;

X = []; %initialise cell array for filling with vel data
Xpos = 1;%initialise X position counter
for i = 1:ldcent
    fr = dcentroids{i, 1};
    lfr =size(fr);
    lfr= lfr(1);
    for j = 1:lfr
          x = round(fr(j, 2)); y = round(fr(j, 3)); mag = fr(j, 7);
          
          if (x>0) && (y>0) && (x<=xl) &&  (y<=yl)
              X{Xpos, 1} = x; X{Xpos, 2} = y; X{Xpos, 3} = mag;
              Xpos = Xpos+1;
          end
          
    end  
        
end

X = cell2mat(X);
XLocs = X(:, 1:2);
mags = X(:, 3);
[N, C] = hist3(XLocs, 'edges', {0:gridincrpix:xl, 0:gridincrpix:yl});
gridmag = zeros(size(N));
gridmagposx = 1;
gridmagposy = 1;

for xloc = 0:gridincrpix:(xl)
    xpos = (X(:, 1)>= xloc & X(:, 1)<(xloc+gridincrpix));
    for yloc = 0:gridincrpix:(yl)
        ypos = (X(:, 2)>= yloc & X(:, 2)<(yloc+gridincrpix));
        xypos = ypos & xpos;
        cellmagsum = sum(mags(xypos));     
        gridmag(gridmagposx, gridmagposy) = cellmagsum;
        gridmagposy = gridmagposy+1;
    end
    gridmagposy = 1;
    gridmagposx = gridmagposx+1;
end

%Dimensionalise gridmag
gridmag = gridmag/metrel;

gridmagav = gridmag./N;
gridmagav(isnan(gridmagav)) = 0;
gridmagav = gridmagav';
gridmagav = flip(gridmagav, 1);

% display
velmap = figure('Name', ([plotname, ' Dimensioned']), 'NumberTitle', 'off');

%Get polygon half widths + dimension
wx= 100*(C{1}(:)-(gridincrpix/2))/metrel;
wy= 100*(((C{2}(:)-(gridincrpix/2))/metrel)+y0m);
H = pcolor(wx, wy, gridmagav);
box on
shading interp
set(H,'edgecolor','none');
c = colorbar;
colormap hot;
set(gca,'Layer','top')
set(gca,'fontsize',24, 'linewidth',3, 'TickLabelInterpreter','latex', 'YColor','k')
c.LineWidth = 3;
c.Label.String = '$$\mbox{Average Velocity Magnitude, }m\cdot s^{-1}$$';
c.Label.Interpreter = 'latex';
c.TickLabelInterpreter = 'latex';
title(plotname,'interpret', 'latex', 'fontsize',24)
xlabel('$$\mbox{x location, } cm$$','interpret', 'latex', 'fontsize',24)
ylabel('$$\mbox{y location, } cm$$','interpret', 'latex', 'fontsize',24)
savefig([plotname, ' Dimensioned']);

end