function h = overobj2(Type)

% function h = overobj2(Type)
% ------------------------------------------------------------------------
% This function searches the current PointerWindow for visible or
% non-visible objects of the type specified by the input Type. It returns
% the handle to the first object it finds under the pointer or, if none are
% found returns an empty matrix. 
% This function is similar to MATLAB's (undocumented) overobj function.
% However it differs in the sense that figure and root units are enforced
% to both be in pixels prior to search. In addition hidden objects (such as
% axes with the axis off option) are also found returned.
% 
% Example: h = overobj2('axes');
%
% Modified from MATLAB's overobj function and the overobj2 function at:
% http://undocumentedmatlab.com/blog/undocumented-mouse-pointer-functions
%
% See also OVEROBJ, FINDOBJ
%
% Kevin Mattheus Moerman
% gibbon.toolbox@gmail.com
% 
% 2015/04/18
% ------------------------------------------------------------------------

%%

%Get figure pointed at
hf = matlab.ui.internal.getPointerWindow();

% Look for quick exit (if mouse pointer is not over any figure)
if hf==0,
   h = [];
   return
end

% Ensure root and figure units are pixels
oldUnitsRoot = get(0,'units');
set(0,'units','pixels');

oldUnitsFig = get(hf,'units');
set(hf,'units','pixels');

%Get position
p = get(0,'PointerLocation');

% Compute figure offset of mouse pointer in pixels
% figPos = getpixelposition(hf);
figPos = get(hf,'Position');

x = (p(1)-figPos(1))/figPos(3);
y = (p(2)-figPos(2))/figPos(4);

%Restore units
set(0,'units',oldUnitsRoot);
set(hf,'units',oldUnitsFig); 

% Loop over all figure descendents
c = findobj(get(hf,'Children'),'flat','Type',Type); %,'Visible','on'
for h = c',
   hUnit = get(h,'Units');
   set(h,'Units','norm')
   r = get(h,'Position');
   set(h,'Units',hUnit)
   if ( (x>r(1)) && (x<r(1)+r(3)) && (y>r(2)) && (y<r(2)+r(4)) )
      return
   end
end
h = [];
 
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
