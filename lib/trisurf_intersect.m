function [P]=trisurf_intersect(TRI1c,N1c,Vn1c,V1,TRI2c,N2c,Vn2c,V2,TRI3c,N3c,Vn3c,V3,d)


%% PREPARING INPUT 1
IND1n=repmat((1:numel(Vn1c(:,1)))'*ones(1,size(Vn2c,1)),[1 1 size(Vn3c,1)]);
IND1n=IND1n(:);

Ax=repmat(Vn1c(:,1)*ones(1,size(Vn2c,1)),[1 1 size(Vn3c,1)]);
Ay=repmat(Vn1c(:,2)*ones(1,size(Vn2c,1)),[1 1 size(Vn3c,1)]);
Az=repmat(Vn1c(:,3)*ones(1,size(Vn2c,1)),[1 1 size(Vn3c,1)]);
V1n=[Ax(:) Ay(:) Az(:)];

Ax=repmat(N1c(:,1)*ones(1,size(N2c,1)),[1 1 size(N3c,1)]);
Ay=repmat(N1c(:,2)*ones(1,size(N2c,1)),[1 1 size(N3c,1)]);
Az=repmat(N1c(:,3)*ones(1,size(N2c,1)),[1 1 size(N3c,1)]);
N1n=[Ax(:) Ay(:) Az(:)];

%% PREPARING INPUT 2
IND2n=repmat(ones(size(Vn1c,1),1)*(1:numel(Vn2c(:,1))),[1 1 size(Vn3c,1)]);
IND2n=IND2n(:);

Bx=repmat(ones(size(Vn1c,1),1)*Vn2c(:,1)',[1 1 size(Vn3c,1)]);
By=repmat(ones(size(Vn1c,1),1)*Vn2c(:,2)',[1 1 size(Vn3c,1)]);
Bz=repmat(ones(size(Vn1c,1),1)*Vn2c(:,3)',[1 1 size(Vn3c,1)]);
V2n=[Bx(:) By(:) Bz(:)];

Bx=repmat(ones(size(N1c,1),1)*N2c(:,1)',[1 1 size(N3c,1)]);
By=repmat(ones(size(N1c,1),1)*N2c(:,2)',[1 1 size(N3c,1)]);
Bz=repmat(ones(size(N1c,1),1)*N2c(:,3)',[1 1 size(N3c,1)]);
N2n=[Bx(:) By(:) Bz(:)];

%% PREPARING INPUT 3
IND3n=permute(repmat((1:numel(Vn3c(:,1)))'*ones(1,size(Vn1c,1)),[1 1 size(Vn2c,1)]),[2 3 1]);
IND3n=IND3n(:);

Cx=permute(repmat(Vn3c(:,1)*ones(1,size(Vn1c,1)),[1 1 size(Vn2c,1)]),[2 3 1]);
Cy=permute(repmat(Vn3c(:,2)*ones(1,size(Vn1c,1)),[1 1 size(Vn2c,1)]),[2 3 1]);
Cz=permute(repmat(Vn3c(:,3)*ones(1,size(Vn1c,1)),[1 1 size(Vn2c,1)]),[2 3 1]);
V3n=[Cx(:) Cy(:) Cz(:)];

Cx=permute(repmat(N3c(:,1)*ones(1,size(N1c,1)),[1 1 size(N2c,1)]),[2 3 1]);
Cy=permute(repmat(N3c(:,2)*ones(1,size(N1c,1)),[1 1 size(N2c,1)]),[2 3 1]);
Cz=permute(repmat(N3c(:,3)*ones(1,size(N1c,1)),[1 1 size(N2c,1)]),[2 3 1]);
N3n=[Cx(:) Cy(:) Cz(:)];

%% Find triangle plane intersections
X=plane_intersect(V1n,V2n,V3n,N1n,N2n,N3n);
L_notnan=~any(isnan(X),2);

%% Check if intersection points lie on triangle
if isempty(X) || all(~L_notnan)
    P=[];
else    
    X=X(L_notnan,:);    
    L1=intriangle(TRI1c(IND1n(L_notnan),:),N1c(IND1n(L_notnan),:),V1,X,d);
    L2=intriangle(TRI2c(IND2n(L_notnan),:),N2c(IND2n(L_notnan),:),V2,X,d);
    L3=intriangle(TRI3c(IND3n(L_notnan),:),N3c(IND3n(L_notnan),:),V3,X,d);
    L=L1&L2&L3;    
    P=X(L,:);
end

end

 
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
