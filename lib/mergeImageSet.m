function [N,G,hf]=mergeImageSet(Nc,Gc,nFac,plotOn)

%Initialise N and G using the first image set
N=Nc{1}; 
G=Gc{1};
for q=2:1:numel(Nc)
    N2=Nc{q}; 
    G2=Gc{q};     
    [N,G]=mergeImageData(N,G,N2,G2,nFac,0);
end

if plotOn==1; 
    %Plot settings
    figColor='w'; 
    figColorDef='white';  
    fontSize=20;    
    tP=1; %Pause time

    %Open figure
    hf=figuremax(figColor,figColorDef);  set(gcf,'renderer','OpenGL');
    xlabel('X (mm)','FontSize',fontSize); ylabel('Y (mm)','FontSize',fontSize); zlabel('Z (mm)','FontSize',fontSize);
    hold on;
    
    %Plotting results
    hp1=[]; 
    for q=1:size(N,4);
        title(['Dynamic ',num2str(q),' of ',num2str(size(N,4))],'FontSize',fontSize);
        delete(hp1); %Delete previous plot handle       
        M=N(:,:,:,q); %Define image to plot
        
        %Define slice selection logic
        L=false(size(M)); 
        L(round(size(M,1)/2),:,:)=1; 
        L(:,round(size(M,2)/2),:)=1; 
        L(:,:,round(size(M,3)/2))=1;        
        
        %Define patch data
        [F,V,C]=ind2patch(L,M,'vb'); %Creating patch data for selection of low voxels
        
        %Convert coordinates
        [V(:,1),V(:,2),V(:,3)]=im2MRcart(V(:,2),V(:,1),V(:,3),G.v,G.OR,G.r,G.c); %Convert image to cartesian coordinates
        
        %Patch the image data
        hp1= patch('Faces',F,'Vertices',V,'FaceColor','flat','CData',C,'EdgeColor','none');
        
        %Axis settings
        axis equal; view(3); axis tight;  grid on;
        colormap('gray'); colorbar;
        set(gca,'FontSize',fontSize);
        drawnow;
        pause(tP); 
    end 
%     pause(tP);
%     close(hf);
else
    hf=NaN;
end

%TO DO: Proper memory allocation for N, currently it grows in the loop
 
%% 
% ********** _license boilerplate_ **********
% 
% Copyright 2017 Kevin Mattheus Moerman
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%   http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
