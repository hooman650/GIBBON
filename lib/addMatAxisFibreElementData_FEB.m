function docNode=addMatAxisFibreElementData_FEB(docNode,FEB_struct)

% function docNode=addMatAxisFibreElementData_FEB(docNode,FEB_struct)
% ------------------------------------------------------------------------
%
%
% 2016/05/12 Taken out of addGeometryLevel_FEB as seperate function to
% replace add_fiber_dir_FEB
%------------------------------------------------------------------------

%%
Vf=FEB_struct.Geometry.ElementData.MatAxis.Basis;
E_ind=FEB_struct.Geometry.ElementData.MatAxis.ElementIndices;

%Get Geometry level
GEONode = docNode.getElementsByTagName('Geometry').item(0);
docRootNode =  GEONode;

%Check for ElementData level
if GEONode.getElementsByTagName('ElementData').getLength==0; %ElementData level does not exist yet
    %Adding ElementData level
    parent_node = docNode.createElement('ElementData');
    parent_node = docRootNode.appendChild(parent_node);
    new_entry=1;
else %ElementData level already exists
    %Finding existing element entries
    no_entries=docRootNode.getElementsByTagName('element').getLength;
    ID_no=zeros(1,no_entries);
    for i=0:1:no_entries-1
        ID_no(i+1)=str2double(docRootNode.getElementsByTagName('element').item(i).getAttribute('id').toCharArray()');
    end
    new_entry=0;
end
docRootNode =  GEONode.getElementsByTagName('ElementData').item(0);

%Creating ElementData entries
if FEB_struct.disp_opt==1;
    hw = waitbar(0,'Creating MatAxis entries...');
end
disp('----> Creating MatAxis entries')

n_steps = numel(E_ind);
for i=1:n_steps
    if new_entry==1 || ~any(ID_no==E_ind(i)); %Need to add element level
        element_node = docNode.createElement('element');
        element_node = docRootNode.appendChild(element_node);
        attr = docNode.createAttribute('id');
        attr.setNodeValue(sprintf('%u',E_ind(i)));
        element_node.setAttributeNode(attr);
    else %element level already exists need to check for fiber entries
        element_node=docRootNode.getElementsByTagName('element').item(find(ID_no==E_ind(i))-1);
    end
    
    if size(Vf,3)==1
        %case 'transiso'
        v_text=sprintf('%6.7e, %6.7e, %6.7e',Vf(i,:));
        if element_node.getElementsByTagName('fiber').getLength==0
            %Adding fiber level
            fiber_node = docNode.createElement('fiber');
            element_node.appendChild(fiber_node);
            %Adding fiber data text
            fiber_node.appendChild(docNode.createTextNode(v_text));
        else %Fiber entries exist, overwriting existing
            element_node.getElementsByTagName('fiber').item(0).getFirstChild.setData(char(v_text));
        end
    else
        %case 'ortho'
        a_text=sprintf('%6.7e, %6.7e, %6.7e',Vf(i,:,1));
        d_text=sprintf('%6.7e, %6.7e, %6.7e',Vf(i,:,2));
        
        if element_node.getElementsByTagName('mat_axis').getLength==0
            %Adding mat_axis level
            mat_axis_node = docNode.createElement('mat_axis');
            element_node.appendChild(mat_axis_node);
            %Adding a level
            a_node = docNode.createElement('a');
            mat_axis_node.appendChild(a_node);
            %Adding a data text
            a_node.appendChild(docNode.createTextNode(a_text));
            %Adding d level
            d_node = docNode.createElement('d');
            mat_axis_node.appendChild(d_node);
            %Adding d data text
            d_node.appendChild(docNode.createTextNode(d_text));
        else %Mat_axis entries exist, overwriting existing
            %Finding mat_axis level
            mat_axis_node=element_node.getElementsByTagName('mat_axis').item(0);
            %Overwriting a level
            mat_axis_node.getElementsByTagName('a').item(0).getFirstChild.setData(char(a_text));
            %Overwriting d level
            mat_axis_node.getElementsByTagName('d').item(0).getFirstChild.setData(char(d_text));
        end
    end
    if FEB_struct.disp_opt==1 && rem(i,round(n_steps/10))==0;
        waitbar(i/n_steps);
    end
end

if FEB_struct.disp_opt==1;
    close(hw); drawnow;
end