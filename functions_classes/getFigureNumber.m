function [figNum] = getFigureNumber()
%This funciton returns the smallest figure number available
%INPUTS:
%       no inputs
%OUTPUTS:
%       figNum
    figHandles=findobj('Type','figure');
    
    figNum = 1;
    if ~isempty(figHandles)
        currentFigNums = sort([figHandles(:).Number]);
        
        fig_i = 1;
        while fig_i <=  max(currentFigNums)
            if figNum ~= currentFigNums(fig_i)
                break;
            end
            fig_i = fig_i + 1;
            figNum = fig_i;
        end
    end
end