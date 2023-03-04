function [strct] = combineStrcts(cellArray, task)
% Combine strctCells from sessions into a big strctCells. 
% Take all the strctCells as elements in a cell array
% Then loop through them and combine
% vwadia Nov 2021

% structs need to have same fields to combine - clever pre-initialization
strct = cellArray{1}; 

for i = 2:length(cellArray)
    
    if strcmp(task, 'Object_Screening')
        if sum(strcmp(fieldnames(cellArray{i}), 'Im_xvals')) == 1
            cellArray{i} = rmfield(cellArray{i}, 'Im_xvals');
        end
        if sum(strcmp(fieldnames(cellArray{i}), 'Im_yvals')) == 1
            cellArray{i} = rmfield(cellArray{i}, 'Im_yvals');
        end
        if sum(strcmp(fieldnames(cellArray{i}), 'recalledStim')) == 1
            cellArray{i} = rmfield(cellArray{i}, 'recalledStim');
        end
    end
    strct = [strct cellArray{i}];
end

end