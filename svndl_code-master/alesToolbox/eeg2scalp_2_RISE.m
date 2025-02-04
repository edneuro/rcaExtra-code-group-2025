h = 10;		% estimated sensor height (mm)
d2 = 30^2;	% distance threshold (mm^2)
% if ispc
% 	scalpFile = 'Z:\anatomy\FREESURFER_SUBS\skeri0074_fs4\bem\skeri0074_fs4-head.fif';
% 	elpFile = 'Z:\projects\nicholas\mrCurrent\MNEstyle\skeri0074\Polhemus\skeri0074_battery_20080808.elp';
% 	regFile = 'Z:\projects\nicholas\mrCurrent\MNEstyle\skeri0074\_MNE_\elp2mri.tran';
% 	eegFile = 'Z:\projects\nicholas\mrCurrent\MNEstyle\skeri0074\Exp_MATL_HCN_128_Avg\Axx_c001.mat';
% else
% 	scalpFile = '/raid/MRI/anatomy/FREESURFER_SUBS/skeri0074_fs4/bem/skeri0074_fs4-head.fif';
% 	elpFile = '/raid/MRI/projects/nicholas/mrCurrent/MNEstyle/skeri0074/Polhemus/skeri0074_battery_20080808.elp';
% 	regFile = '/raid/MRI/projects/nicholas/mrCurrent/MNEstyle/skeri0074/_MNE_/elp2mri.tran';
% 	eegFile = '/raid/MRI/projects/nicholas/mrCurrent/MNEstyle/skeri0074/Exp_MATL_HCN_128_Avg/Axx_c001.mat';
% end
% 


subjId = 'skeri0069';

scalpFile = ['/Volumes/Denali_MRI/anatomy/FREESURFER_SUBS/' subjId '_fs4/bem/' subjId '_fs4-head.fif'];

%elpFile = ['/Volumes/MRI/data/4D2/JMA_PROJECTS/c1v1flip/mrcProj/' subjId '/Polhemus/AW_crf2_20090519.elp'];
%elpFile = ['/Volumes/MRI/data/4D2/JMA_PROJECTS/c1v1flip/mrcProj/' subjId '/Polhemus/JA_ATTCont_20090225.elp'];
elpFile = ['/Volumes/Denali_4D2/4D2/JMA_PROJECTS/c1v1flip/mrcProj/' subjId '/Polhemus/MQM_chpstxDual2Cond_20090414.elp'];
regFile = ['/Volumes/Denali_4D2/4D2/JMA_PROJECTS/c1v1flip/mrcProj/' subjId '/_MNE_/elp2mri.tran'];
% eegFile = ['/Volumes/Denali_4D2/4D2/JMA_PROJECTS/c1v1flip/mrcProj/' subjId '/Exp_MATL_HCN_128_Avg/Axx_c903.mat'];
% eegIndex = 45;


S = mne_read_bem_surfaces(scalpFile);
S.rr = S.rr*1e3;					% convert to mm
S.tris = flipdim(S.tris,2);	% outward normals of matlab patch
S.np = double(S.np);

e = mrC_readELPfile(elpFile,true,true,[-2 1 3]);
xfm = load('-ascii',regFile);
ex = [e(1:128,:)*1e3,ones(128,1)]*(xfm(1:3,:)');

% eegStruct = load(eegFile);
% eeg = eegStruct.Wave(eegIndex,:);

bgc = [0 0 0]+0.75;		% scalp background color

%% load data

for i=1:6
eegFile = ['/Volumes/MRI/data/4D2/JMA_PROJECTS/c1v1flip/mrcProj/' subjId '/Exp_MATL_HCN_128_Avg/Axx_c95' num2str(i) '.mat'];
eegStruct = load(eegFile);
allEeg{i} = eegStruct;
eegIndex =50;
eeg{i} = eegStruct.Wave(eegIndex,:);
end

%%
clf
colormap([bgc;jet(255)])

P = patch('vertices',S.rr,'faces',S.tris(:,[1 2 3]),'edgecolor','none','facecolor',bgc);
L = [ light('position',[1e3 1e3 1e3]), light('position',[-1e3 -1e3 1e3]) ];
set(L,'color','w','style','local');

set(gca,'view',[90 0],'dataaspectratio',[1 1 1],'xcolor','r','ycolor',[0 0.5 0],'zcolor','b')
xlabel('right')
ylabel('anterior')
zlabel('superior')

%  E = patch('vertices',e,'faces',flipdim(mrC_EGInetFaces(false),2),'facecolor','none',...
%  	'facevertexcdata',2+round(127*(1+eeg(:)/max(abs(eeg)))),'edgecolor','interp');

% N = get(E,'vertexnormals');
% N = N ./ repmat(sqrt(sum(N.^2,2)),1,3);
% ex = ex - N*h;
% set(E,'vertices',ex)

%%
d2map = zeros(128,S.np);
for i = 1:128
	[junk,d2map(i,:)] = nearpoints( S.rr', ex(i,:)' );
end
dToo = min(d2map) > 30^2;
d2map = exp(-d2map/(20^2));
d2map = d2map ./ repmat(sum(d2map),128,1);
% toc

%%
eegIndex =20;
eeg = eegStruct.Wave(eegIndex,:);

cdata = ( eeg*d2map )';
% dog = zeros(1,128); dog(109) = 1; cdata = ( dog*d2map )';
%cdata = 2 + round( 127*( 1 + cdata/max(abs(cdata)) ) );
%cdata(dToo) = 1;

cdata = 2 + round( 127*( 1 + cdata/max(abs(cdata)) ) );
eegData = 2 + round( 127*( 1 + eeg/max(abs(eeg)) ) );

cdata(dToo) = 1;

set(P,'facevertexcdata',cdata,'facecolor','interp')
set(E,'facevertexcdata',eegData')



%% countour ify cdata
minDat = min(min(meanAmp(1,1,:,1,:)));
maxDat = .8;max(max(meanAmp(1,1,:,1,:)));
rangeDat = abs(maxDat-minDat);

%set vertex cdata
for iC =1:20;
cdata = ( squeeze(meanAmp(1,1,iC,1,:))'*d2map )';

%cdata = (eeg*d2map)';

nContours = 9;

%Scale cdata 0 -> 1
cdata = min(cdata,maxDat);
cdata = (cdata-minDat);
cdata = cdata/rangeDat;

%Scale cdata -1 -> 1
%cdata =  (cdata/max(abs(cdata)));

%Scale cdata 0 -> 1
%cdata = (cdata+min(cdata))/2;


%scale data to be 3->nContours.
cdata = round(nContours*cdata)+3;

%Get values at each vertex of a face.
tV(:,1) = cdata(S.tris(:,1));
tV(:,2) = cdata(S.tris(:,2));
tV(:,3) = cdata(S.tris(:,3));

%Find faces that are at a contour boundary.
samFace = (tV(:,1)==tV(:,2)) & (tV(:,1) == tV(:,3)) & (tV(:,2) == tV(:,3));

%Find the vertices involved with contour boundary faces.
lV = S.tris(~samFace,:);
lV = unique(lV(:));

%set contour boundary vertices to 2;
cdata(lV) = 2;

%Set non cap points to 1;
cdata(dToo)=1;




cmap = jmaColors('hotcortex',[],nContours+1);
cmap = [.6 .6 .6; 0 0 0; cmap];
colormap(cmap);

rgbCdata = cmap(cdata,:);
set(P,'facevertexcdata',rgbCdata,'cdatamapping','direct')

%caxis([1 nContours+3])


drawnow;
scalpMovie(iC) = getframe;
%saveas(gcf,['contourCortex_cnd95' num2str(iC) '.png'],'png');
%pause
end


%%
cohVals = linspace(0,100,20);
figure(5)
clf
i=20;
set(gcf,'color','white')
errorbar(cohVals(1:i),squeeze(mean(allSignal(:,1,2:(i+1),1,91))),stdErrInc(1:i),'-k.','linewidth',3,'markersize',30)
hold on;
errorbar(cohVals(1:i),squeeze(mean(allNoise(:,1,2:(i+1),1,91))),stdErrIncNoise(1:i),'-','linewidth',3,'markersize',30,'color',[.4 .4 .4])
axis([-1 101 0 1])
xlabel('Coherence','fontsize',20,'fontname','helvetica')
ylabel('Microvolts','fontsize',20,'fontname','helvetica')
set(gca,'fontsize',20,'fontname','helvetica','linewidth',2,'box','off')

for i=1:20,
    lineH=line([cohVals(i) cohVals(i) ],[1 0],'linestyle','--','color','k','linewidth',2);
    chan91Movie(i) = getframe(gcf);
    drawnow
    delete(lineH)

end

%%
E = patch('vertices',ex,'faces',flipdim(mrC_EGInetFaces(false),2),'facecolor','none','edgecolor','k');


