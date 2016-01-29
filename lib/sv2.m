function hf=sv2(varargin)

%% Parse input

switch nargin
    case 1
        M=varargin{1};
        v=ones(1,3);
    case 2
        M=varargin{1};
        v=varargin{2};  
end

%%

M=double(M);

%%
% Plot settings
fontSize=10;
fontColor='w';
cMap=gray(250);

figStruct.vcw=0; %Currently not compatible with vcw
figStruct.Name='GIBBON: Slice viewer'; %Figure name
figStruct.Color='k'; %Figure background color
figStruct.ColorDef='black'; %Setting colordefinitions to black
% figStruct.ScreenOffset=20; %Setting spacing of figure with respect to screen edges

%%

%Defining row, column and slice indicices for slice patching
sliceIndexI=round(size(M,1)/2); %(close to) middle row
sliceIndexJ=round(size(M,2)/2); %(close to) middle column
sliceIndexK=round(size(M,3)/2); %(close to) middle slice

Tf=[0 100]; %Threshold

%%

[ax,ay,az]=im2cart([size(M,1)+1 0],[size(M,2)+1 0],[size(M,3)+1 0],v);
axLim=[ax(2) ax(1) ay(2) ay(1) az(2) az(1)];

hf=cFigure(figStruct);

for q=1:1:4
    subplot(2,2,q);
    xlabel('X'); ylabel('Y'); zlabel('Z');
    hold on;
    axis equal; axis tight; axis vis3d; axis(axLim); grid on; box on;
    
    switch q
        case 1
            title('JK-view','color','r');
            view(0,0);
        case 2
            title('IK-view','color','g');
            view(-90,0);
        case 3
            title('IJ-view','color','b');
            view(0,90);
        case 4
            title(['IJK-view ',num2str(sliceIndexI),' ',num2str(sliceIndexJ),' ',num2str(sliceIndexK)],'color',fontColor);
            colorbar;
            view(3);
    end
    colormap(cMap);
    caxis([min(M(:)) max(M(:))]);
    set(gca,'fontSize',fontSize);
    H(q)=gca;
end
drawnow;

%% Set user data
hf.UserData.M=M;
hf.UserData.v=v;
hf.UserData.patchTypes={'si','sj','sk'};
hf.UserData.H=H;
hf.UserData.hp=[];
hf.UserData.hpp=[];
hf.UserData.sliceIndices=[sliceIndexI sliceIndexJ sliceIndexK];
hf.UserData.axLim=axLim;
hf.UserData.logicThreshold=true(size(M));
hf.UserData.fontColor=fontColor;

updateSlices(hf);
 
%%

set(hf,'WindowButtonDownFcn', {@ButtonDownFunction,hf},'BusyAction','cancel');

%% Create slider for tresholding

w=50; %Scrollbar width

jSlider_T = com.jidesoft.swing.RangeSlider(0,100,Tf(1),Tf(2));  % min,max,low,high
javacomponent(jSlider_T,[0,0,w,round(hf.Position(4))]);
set(jSlider_T, 'MajorTickSpacing',25, 'MinorTickSpacing',1, 'PaintTicks',true, 'PaintLabels',true,...
    'Background',java.awt.Color.white, 'snapToTicks',false, 'StateChangedCallback',{@setThreshold,{hf,jSlider_T}},'Orientation',jSlider_T.VERTICAL);

set(jSlider_T,'LowValue',Tf(1));
set(jSlider_T,'HighValue',Tf(2));

%% Set resize function

set(hf,'ResizeFcn',{@setScrollSizeFunc,{hf,w,jSlider_T}});

end

function ButtonDownFunction(~,~,hf)
v=hf.UserData.v;

cax = overobj2('axes');

if isempty(cax)
    %     cax=gca; %this gets current axis or if none exists creates one
    cax = get(hf, 'CurrentAxes');
else
    axes(cax)
end

if isempty(cax)
    return
end

%Key actions
pt_ax = get(cax, 'CurrentPoint');

if cax==hf.UserData.H(1) %JK view -> I slice
    %     hp=plot(pt_ax(1,1),pt_ax(1,3),'r.');
    [~,jj,kk]=cart2im(pt_ax(1,1),0,pt_ax(1,3),v);
    jj=round(jj);
    kk=round(kk);
    hf.UserData.sliceIndices(2)=jj;
    hf.UserData.sliceIndices(3)=kk;
elseif cax==hf.UserData.H(2) %IK view -> J slice
    %     hp=plot(pt_ax(1,1),pt_ax(1,3),'r.');
    [ii,~,kk]=cart2im(0,pt_ax(1,2),pt_ax(1,3),v);
    ii=round(ii);
    kk=round(kk);
    hf.UserData.sliceIndices(1)=ii;
    hf.UserData.sliceIndices(3)=kk;
elseif cax==hf.UserData.H(3) %IJ view -> K slice
    %     hp=plot(pt_ax(1,1),pt_ax(1,2),'r.');
    [ii,jj,~]=cart2im(pt_ax(1,1),pt_ax(1,2),0,v);
    ii=round(ii);
    jj=round(jj);
    hf.UserData.sliceIndices(1)=ii;
    hf.UserData.sliceIndices(2)=jj;
else     
    return
end

updateSlices(hf);

end

function updateSlices(hf)

sliceIndices = hf.UserData.sliceIndices;
M=hf.UserData.M;
v=hf.UserData.v;
axLim=hf.UserData.axLim;
[xx,yy,zz]=im2cart(sliceIndices(1),sliceIndices(2),sliceIndices(3),v);

for dirOpt=1:1:3
    patchType=hf.UserData.patchTypes{dirOpt};
    logicPatch=false(size(M));
    sliceIndex=sliceIndices(dirOpt);
    
    switch dirOpt
        case 1
            logicPatch(sliceIndex,:,:)=1;
        case 2
            logicPatch(:,sliceIndex,:)=1;
        case 3
            logicPatch(:,:,sliceIndex)=1;
    end
    
    [F,V,C]=ind2patch(logicPatch & hf.UserData.logicThreshold,M,patchType);
    [V(:,1),V(:,2),V(:,3)]=im2cart(V(:,2),V(:,1),V(:,3),v);
    
    if isfield(hf.UserData,'hp');
        try
            delete(hf.UserData.hp(dirOpt));
        catch
        end
    end
    subplot(2,2,dirOpt);
    hf.UserData.hp(dirOpt)= patch('Faces',F,'Vertices',V,'FaceColor','flat','CData',C,'EdgeColor','none');
    
    
    f=[1:4];
    switch dirOpt
        case 1
            if isfield(hf.UserData,'hpp');
                try
                    delete(hf.UserData.hpp(1));
                    delete(hf.UserData.hpp(2));
                catch
                end
            end
            vv=[xx axLim(3) axLim(6); xx axLim(4) axLim(6); xx axLim(4) axLim(5); xx axLim(3) axLim(5);];
            hf.UserData.hpp(1)=patch('faces',f,'vertices',vv,'faceColor','g','EdgeColor','g','faceAlpha',0.1);
            vv=[axLim(1) axLim(3) zz; axLim(2) axLim(3) zz; axLim(2) axLim(4) zz; axLim(1) axLim(4) zz;];
            hf.UserData.hpp(2)=patch('faces',[1 2 3 4],'vertices',vv,'faceColor','b','EdgeColor','b','faceAlpha',0.1);
        case 2
            if isfield(hf.UserData,'hpp');
                try
                    delete(hf.UserData.hpp(3));
                    delete(hf.UserData.hpp(4));
                catch
                end
            end
            vv=[axLim(1) yy axLim(5); axLim(2) yy axLim(5); axLim(2) yy axLim(6); axLim(1) yy axLim(6);];
            hf.UserData.hpp(3)=patch('faces',f,'vertices',vv,'faceColor','r','EdgeColor','r','faceAlpha',0.1);
            vv=[axLim(1) axLim(3) zz; axLim(2) axLim(3) zz; axLim(2) axLim(4) zz; axLim(1) axLim(4) zz;];
            hf.UserData.hpp(4)=patch('faces',f,'vertices',vv,'faceColor','b','EdgeColor','b','faceAlpha',0.1);
        case 3
            if isfield(hf.UserData,'hpp');
                try
                    delete(hf.UserData.hpp(5));
                    delete(hf.UserData.hpp(6));
                catch
                end
            end
            vv=[axLim(1) yy axLim(5); axLim(2) yy axLim(5); axLim(2) yy axLim(6); axLim(1) yy axLim(6);];
            hf.UserData.hpp(5)=patch('faces',f,'vertices',vv,'faceColor','r','EdgeColor','r','faceAlpha',0.1);
            vv=[xx axLim(3) axLim(6); xx axLim(4) axLim(6); xx axLim(4) axLim(5); xx axLim(3) axLim(5);];
            hf.UserData.hpp(6)=patch('faces',f,'vertices',vv,'faceColor','g','EdgeColor','g','faceAlpha',0.1);
    end
end
subplot(2,2,4);
if isfield(hf.UserData,'hp');
    try
        delete(hf.UserData.hp(4));
        delete(hf.UserData.hp(5));
        delete(hf.UserData.hp(6));
    catch
    end
end
title(['IJK-view ',num2str(sliceIndices(1)),' ',num2str(sliceIndices(2)),' ',num2str(sliceIndices(3))],'color',hf.UserData.fontColor);
hf.UserData.hp(4)=patch('Faces',get(hf.UserData.hp(1),'Faces'),'Vertices',get(hf.UserData.hp(1),'Vertices'),'FaceColor','flat','CData',get(hf.UserData.hp(1),'CData'),'EdgeColor','none');
hf.UserData.hp(5)=patch('Faces',get(hf.UserData.hp(2),'Faces'),'Vertices',get(hf.UserData.hp(2),'Vertices'),'FaceColor','flat','CData',get(hf.UserData.hp(2),'CData'),'EdgeColor','none');
hf.UserData.hp(6)=patch('Faces',get(hf.UserData.hp(3),'Faces'),'Vertices',get(hf.UserData.hp(3),'Vertices'),'FaceColor','flat','CData',get(hf.UserData.hp(3),'CData'),'EdgeColor','none');

drawnow;

end

function setThreshold(~,~,inputCell)

hf=inputCell{1};
jSlider_T=inputCell{2};

Tf(1) = get(jSlider_T,'LowValue');
Tf(2) = get(jSlider_T,'HighValue');

M=hf.UserData.M;
W=max(M(:))-min(M(:));

T_low=min(M(:))+(W*Tf(1)/100);
T_high=min(M(:))+(W*Tf(2)/100);
logicThreshold=(M>=T_low & M<=T_high);
hf.UserData.logicThreshold=logicThreshold;

updateSlices(hf);

end

function setScrollSizeFunc(~,~,inputCell)
hf=inputCell{1};
w=inputCell{2};
jSlider=inputCell{3};
javacomponent(jSlider,[0,0,w,round(hf.Position(4))]);
end

