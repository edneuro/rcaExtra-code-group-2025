function vAnatomyFiducials(vAnatomyPath)
% Create text file of [LA;RA;NZ] fiducials in RAS voxel coords from vAnatomy.dat
%
% SYNTAX:   vAnatomyFiducials
%           vAnatomyFiducials(vAnatomyPath)

if ~exist('vAnatomyPath','var')
	[vAnatFile,vAnatPath] = uigetfile('vAnatomy.dat','Choose vAnatomy.dat file');
	if isnumeric(vAnatFile)
		return
	end
	vAnatomyPath = [vAnatPath,vAnatFile];
end


[V,mmVox] = readVolAnat(vAnatomyPath);		% V is IPR
if ~all(mmVox == [1 1 1])
	error('Voxel dimensions not 1x1x1mm')
end
if ~all(size(V) == [256 256 256])
	error('Volume not 256 voxel cube')
end
V(:) = permute(V,[3 2 1]);		% RPI
V(:) = flipdim(V,2);				% RAI
V(:) = flipdim(V,3);				% RAS

BGcolor = [0 0.1 0.2];
FGcolor = 'w';
Rcolor = 'r';
Acolor = 'g';
Scolor = 'c';
boxColor = [0.5 0.5 0.5];

i = [128 128 128];
ax = zeros(1,3);
lineR = zeros(1,2);
lineA = zeros(1,2);
lineS = zeros(1,2);
fVoxVal = [NaN NaN NaN];	% values in V of [LA RA NZ] selections

% V = 0-255, colormap = 1-256, 0&1 map to black, 256 is reserved for tagging fiducial voxels
figure('Color',BGcolor,'Colormap',[gray(255);1 0 1],'defaultuicontrolunits','normalized',...
		'name',vAnatomyPath)


ax(1) = axes('Position',[0.10 0.50 0.4 0.4]);
	imgA = image(squeeze(V(:,i(2),:))');
	lineR(1) = line(i([1 1]),[0 256],'color',Rcolor);
	lineS(1) = line([0 256],i([3 3]),'color',Scolor);
	xlabel('R \rightarrow','color',Rcolor)
	ylabel('S \rightarrow','color',Scolor)
ax(2) = axes('Position',[0.55 0.50 0.4 0.4]);
	imgR = image(squeeze(V(i(1),:,:))');
	lineA(1) = line(i([2 2]),[0 256],'color',Acolor);
	lineS(2) = line([0 256],i([3 3]),'color',Scolor);
	xlabel('A \rightarrow','color',Acolor)
ax(3) = axes('Position',[0.10 0.05 0.4 0.4]);
	imgS = image(V(:,:,i(3))');
	lineR(2) = line(i([1 1]),[0 256],'color',Rcolor);
	lineA(2) = line([0 256],i([2 2]),'color',Acolor);
	ylabel('A \rightarrow','color',Acolor)
set(ax,'YDir','normal','XAxisLocation','top','XTick',[],'YTick',[],...
	'XColor',boxColor,'YColor',boxColor,'Box','on','DataAspectRatio',[1 1 1])
set([imgA,imgR,imgS],'ButtonDownFcn',@moveCrosshairs)
set([lineR,lineA,lineS],'HitTest','off')

% SLICE CONTROLS
uicontrol('position',[0.55 0.40 0.05 0.05],'style','text','string','R','foregroundcolor',Rcolor,'backgroundcolor',BGcolor)
uicontrol('position',[0.55 0.35 0.05 0.05],'style','text','string','A','foregroundcolor',Acolor,'backgroundcolor',BGcolor)
uicontrol('position',[0.55 0.30 0.05 0.05],'style','text','string','S','foregroundcolor',Scolor,'backgroundcolor',BGcolor)
UIslice = [ ...
uicontrol('position',[0.60 0.40 0.30 0.05],'style','slider','min',1,'max',256,'value',i(1),'sliderstep',[1 10]/255,'tag','sliderR','callback',@setSlice),...
uicontrol('position',[0.60 0.35 0.30 0.05],'style','slider','min',1,'max',256,'value',i(2),'sliderstep',[1 10]/255,'tag','sliderA','callback',@setSlice),...
uicontrol('position',[0.60 0.30 0.30 0.05],'style','slider','min',1,'max',256,'value',i(3),'sliderstep',[1 10]/255,'tag','sliderS','callback',@setSlice),...
uicontrol('position',[0.90 0.40 0.05 0.05],'style','edit','string',i(1),'tag','editR','callback',@setSlice),...
uicontrol('position',[0.90 0.35 0.05 0.05],'style','edit','string',i(2),'tag','editA','callback',@setSlice),...
uicontrol('position',[0.90 0.30 0.05 0.05],'style','edit','string',i(3),'tag','editS','callback',@setSlice),...
];

% FIDUCIAL CONTROLS
uicontrol('position',[0.55 0.20 0.05 0.05],'style','text','string','LA','backgroundcolor',BGcolor,'foregroundcolor',FGcolor)
uicontrol('position',[0.55 0.15 0.05 0.05],'style','text','string','RA','backgroundcolor',BGcolor,'foregroundcolor',FGcolor)
uicontrol('position',[0.55 0.10 0.05 0.05],'style','text','string','NZ','backgroundcolor',BGcolor,'foregroundcolor',FGcolor)
UIfiducial = [ ...
uicontrol('position',[0.60 0.20 0.17 0.05],'style','edit','enable','off','value',[]),...
uicontrol('position',[0.60 0.15 0.17 0.05],'style','edit','enable','off','value',[]),...
uicontrol('position',[0.60 0.10 0.17 0.05],'style','edit','enable','off','value',[]),...
];
uicontrol('position',[0.77 0.20 0.06 0.05],'style','pushbutton','string','click','tag','LA','callback',@clickPoint)
uicontrol('position',[0.77 0.15 0.06 0.05],'style','pushbutton','string','click','tag','RA','callback',@clickPoint)
uicontrol('position',[0.77 0.10 0.06 0.05],'style','pushbutton','string','click','tag','NZ','callback',@clickPoint)
uicontrol('position',[0.83 0.20 0.06 0.05],'style','pushbutton','string','set','tag','LA','callback',@setPoint)
uicontrol('position',[0.83 0.15 0.06 0.05],'style','pushbutton','string','set','tag','RA','callback',@setPoint)
uicontrol('position',[0.83 0.10 0.06 0.05],'style','pushbutton','string','set','tag','NZ','callback',@setPoint)
uicontrol('position',[0.89 0.20 0.06 0.05],'style','pushbutton','string','goto','tag','LA','callback',@gotoPoint)
uicontrol('position',[0.89 0.15 0.06 0.05],'style','pushbutton','string','goto','tag','RA','callback',@gotoPoint)
uicontrol('position',[0.89 0.10 0.06 0.05],'style','pushbutton','string','goto','tag','NZ','callback',@gotoPoint)

% LOAD,SAVE
uicontrol('position',[0.60 0.05 0.17 0.05],'style','pushbutton','string','LOAD','callback',@loadFiducials) %,'backgroundcolor',[0 0.4 0.8],'foregroundcolor','k')
uicontrol('position',[0.77 0.05 0.18 0.05],'style','pushbutton','string','SAVE','callback',@saveFiducials) %,'backgroundcolor',[0 0.4 0.8],'foregroundcolor','k')

return


	function setSlice(H,varargin)
		switch get(H,'tag')
		case 'sliderR'
			updateSlice(get(H,'value'),1)
		case 'sliderA'
			updateSlice(get(H,'value'),2)
		case 'sliderS'
			updateSlice(get(H,'value'),3)
		case 'editR'
			updateSlice(eval(get(H,'string')),1)
		case 'editA'
			updateSlice(eval(get(H,'string')),2)
		case 'editS'
			updateSlice(eval(get(H,'string')),3)
		end
	end

	function updateSlice(val,dim)
		val = round(min(max(val,1),256));
		if i(dim) ~= val
			i(dim) = val;
			switch dim
			case 1
				set(lineR,'XData',i([1 1]))
				set(UIslice(1),'value',i(1))
				set(UIslice(4),'string',i(1))
				set(imgR,'CData',squeeze(V(i(1),:,:))')
			case 2
				set(lineA(1),'XData',i([2 2]))
				set(lineA(2),'YData',i([2 2]))
				set(UIslice(2),'value',i(2))
				set(UIslice(5),'string',i(2))
				set(imgA,'CData',squeeze(V(:,i(2),:))')
			case 3
				set(lineS,'YData',i([3 3]))
				set(UIslice(3),'value',i(3))
				set(UIslice(6),'string',i(3))
				set(imgS,'CData',V(:,:,i(3))')
			end
		end
	end

	function moveCrosshairs(varargin)
		k = gca == ax;
		xyz = get(ax(k),'currentpoint');
		if k(1)
			updateSlice(xyz(1,1),1)
			updateSlice(xyz(1,2),3)
		elseif k(2)
			updateSlice(xyz(1,1),2)
			updateSlice(xyz(1,2),3)
		else
			updateSlice(xyz(1,1),1)
			updateSlice(xyz(1,2),2)
		end
	end

	function clickPoint(H,varargin)
		ginput(1);
		moveCrosshairs
		setPoint(H)
	end

	function setPoint(H,varargin)
		f = strcmp({'LA','RA','NZ'},get(H,'tag'));
		old = get(UIfiducial(f),'value');
		if ~isempty(old)
			V(old(1),old(2),old(3)) = fVoxVal(f);
		end
		fVoxVal(f) = V(i(1),i(2),i(3));
		V(i(1),i(2),i(3)) = 256;
		set(UIfiducial(f),'string',sprintf('%g, %g, %g',i),'value',i)
		set(imgR,'CData',squeeze(V(i(1),:,:))')		% color voxel under crosshair
		set(imgA,'CData',squeeze(V(:,i(2),:))')
		set(imgS,'CData',V(:,:,i(3))')
	end

	function gotoPoint(H,varargin)
		i2 = get(UIfiducial(strcmp({'LA','RA','NZ'},get(H,'tag'))),'value');
		for dim = 1:3
			updateSlice(i2(dim),dim)
		end
	end

	function loadFiducials(varargin)
		[filename,pathname] = uigetfile('*.txt','Fiducial text file');
		if isnumeric(filename)
			return
		end
		P = load('-ascii',[pathname,filename]);
		if ~all(size(P)==[3 3])
% 			error('%s doesn''t contain a 3x3 ascii matrix',[pathname,filename])
			uiwait(errordlg({filename;'doesn''t contain 3x3 ascii matrix'},'Invalid file')),return
		end
		P = P + 128;
		for f = 1:3
			set(UIfiducial(f),'string',sprintf('%d, %d, %d',P(f,:)),'value',P(f,:))
		end
	end

	function saveFiducials(varargin)
		P = [ get(UIfiducial(1),'value'); get(UIfiducial(2),'value'); get(UIfiducial(3),'value') ];
		if ~all(size(P)==[3 3])
% 			error('must set all 3 fiducials before saving')
			uiwait(errordlg({'Set LA, RA, and NZ';'Not saving'},'Incomplete fiducials')),return
		end
		if P(2,1) < P(1,1)
			uiwait(errordlg({'RA is left of LA';'Not saving'},'Implausible fiducials')),return
		end
		P = P - 128;
		[vAnatPath,vAnatFile] = fileparts(vAnatomyPath);
		[junk,subjid] = fileparts(vAnatPath);
 		[filename,pathname] = uiputfile('*.txt','Fiducial text file',fullfile(vAnatPath,[subjid,'_fiducials.txt']));
%		[filename,pathname] = uiputfile(fullfile(SKERIanatDir,'FREESURFER_SUBS','*.txt'),'Fiducial text file',[subjid,'_fiducials.txt']);
		if isnumeric(filename)
			return
		end
		save([pathname,filename],'P','-ascii','-tabs')
		disp(['wrote ',pathname,filename])
	end

end

% fv = isosurface(V,25);		% takes forever
% H = patch(fv,'facecolor','y','edgecolor','none','facelighting','gouraud');
% isonormals(V,H)