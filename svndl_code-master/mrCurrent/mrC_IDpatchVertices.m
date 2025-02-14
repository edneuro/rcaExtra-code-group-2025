function mrC_IDpatchVertices(IDstate,textColor,Hpatch)
% Show vertex #s for the current patch object
% e.g. electrode #s for a sensor mesh
%
% usage:
% mrC_IDpatchVertices         - blinkd text labels for 2 seconds
% mrC_IDpatchVertices on      - turn on text labels
% mrC_IDpatchVertices off     - turn off text labels
% mrC_IDpatchVertices blink g - blink green text labels
%
% Operates on the current graphics object, if it's a patch
% or the patch in the current axis, if there's only one
% or the patch anywhere in your matlab environment, if there's only one
% otherwise click on a patch and try again
%
% This is designed for patches of 128 channel elp-file data generated by mrCurrent,
% however it will run for any patch with <= 257 vertices.
% If using it for non-mrCurrent patches,
% be warned the text labels are simply the vertex #s of the patch object

% (c) 2010 Spero Nicholas
% The Smith-Kettlewell Eye Research Institute


tagStr = mfilename;

if ~exist('textColor','var') || isempty(textColor)
	textColor = [0 0 0];
elseif ~( ischar(textColor) && isscalar(textColor) && any(textColor=='rgbcmykw') )
	if ~isnumeric(textColor) || numel(textColor)~=3 || ~all([size(textColor,1),size(textColor,2)]==[1 3]) || min(textColor)<0 || max(textColor)>1
		error('Input "textColor" is not a valid string or RGB triplet.')
	end
end

if ~exist('Hpatch','var') || isempty(Hpatch)
	Hpatch = gco;
	if ~strcmp(get(Hpatch,'Type'),'patch')
		Hpatch = findobj(gca,'Type','patch');
		if isempty(Hpatch)
			Hpatch = findobj('Type','patch');
		end
		if numel(Hpatch) ~= 1
			disp(Hpatch)
			error('%s can''t tell what patch you want to ID.',tagStr)
		end
	end
elseif ~isnumeric(Hpatch) || ~isscalar(Hpatch) || ~ishandle(Hpatch) || ~strcmp(get(Hpatch,'Type'),'patch')
	error('Input "Hpatch" is not a valid patch object handle.')
end

Hax = get(Hpatch,'parent');

if ~exist('IDstate','var') || isempty(IDstate)
	Htext = findobj(Hax,'Type','text','Tag',tagStr,'UserData',Hpatch);
	if isempty(Htext)
		IDstate = 'blink';
	else
		IDstate = 'off';
	end
end

switch IDstate
case 'on'
	Htext = findobj(Hax,'Type','text','Tag',tagStr,'UserData',Hpatch);
	if ~isempty( Htext )
		set(Htext,'Color',textColor)
		disp('Vertices already labeled.')
		return
	end	
	V = get(Hpatch,'Vertices');
	nV = size(V,1);
	if nV > 257
		error('Patch has too many vertices (%d).',nV)
	end

	Htext = zeros(nV,1);
	axes(Hax)
	for i = 1:nV
		Htext(i) = text(V(i,1),V(i,2),V(i,3),int2str(i));
	end
	set(Htext,'Tag',tagStr,'UserData',Hpatch,...
		'HorizontalAlignment','center','VerticalAlignment','middle',...
		'FontSize',8,'FontWeight','normal','Color',textColor)
case 'off'
	if ~exist('Htext','var')
		Htext = findobj(Hax,'Type','text','Tag',tagStr,'UserData',Hpatch);
	end
	delete(Htext)
case 'blink'
	mrC_IDpatchVertices('on',textColor,Hpatch)
	drawnow
	pause(2)
	mrC_IDpatchVertices('off',textColor,Hpatch)
end

