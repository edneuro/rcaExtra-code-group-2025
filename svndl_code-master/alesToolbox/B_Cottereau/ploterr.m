function [h,Options]=ploterr(x,y,s,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lives in 'V:\4D2\Disparity\Cottereau'
% ploterr - plot with a patch representing dispersion/error around the value
% [h]=ploterr(x,y,s)
% [h]=ploterr(x,y,s, 'Color', [r g b], 'PatchColor', [r g b])
% [h]=ploterr(y,s)
% [h]=ploterr(y)
%
% Plots data y with their dispersion s, given abscissa x.
%INPUTS:
%   x: T-long vector, abscissa for data point (if not given: x=[1:length(y)])
%   y: T-by-N matrix of mean data points (N may be 1)
%   s: T-by-N matrix of dispersion around mean for each data point
%OUTPUT:
%   h is N-by-2 array of handles: h(:,1) are the lines, h(:,2) the patches
%
% If no s is provided. Default is to plot the STANDARD ERROR around the
% mean: 
%       s=std(y)/n;
%       y=mean(y);
% ie. y is assumed to be a [ K x T x N ] matrix (of K observations/subjects) 
%
% Date: 06/29/2011
% Script: Benoit R. Cottereau.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<2
    y=x;
    x=[];
end
if nargin<3
    s=[];
end
if ~isempty(s) && ischar(s)
    varargin=[{s} varargin];
    s=[];    
end
Options.Color = get(gca, 'ColorOrder');
Options.PatchColor = brighten(Options.Color,.97);

if nargin > 3
    Options = mergestructs(Options,struct(varargin{:}));
% Options.Color=varargin{1}.;
% Options.PatchColor=varargin{2};
end

if isempty(s)
    s = shiftdim(std(y),1)./sqrt(size(y,1));
    y = shiftdim(mean(y),1);
end
if isempty(x)
    x = [1:size(y,1)]';
end

if prod(size(y)) ~= max(size(y))
    Ys = y;
    holdstate = ishold;
    y = y(:,:);
    s = s(:,:);
    for i = 1 : size(y,2)
        o = Options;
        o.Color = circshift(Options.Color,1-i);
        o.PatchColor = circshift(Options.PatchColor,1-i);
        [h(i,:)] = ploterr(x,y(:,i),s(:,i),o);
        hold on
    end    
    if ~holdstate
        hold off
    end
    return
end

px = [x(:); flipud(x(:))];    % use px=[x1;x2(end:-1:1)]; if row vecs
py = [ y(:)-s(:) ; flipud(y(:)+s(:)) ];    % use ...

holdstate = ishold;
if ~holdstate
    delete(get(gca, 'Children'))
end
h = patch(px, py, Options.PatchColor(1,:));
%set(h, 'FaceAlpha', .5)
set(h, 'EdgeAlpha', 0)
hold on
h = [plot(x,y, 'LineWidth', 2,'Color', Options.Color(1,:)) h];
set([h(:,2)], 'FaceAlpha', .35);
if ~holdstate
    hold off;
end

return

