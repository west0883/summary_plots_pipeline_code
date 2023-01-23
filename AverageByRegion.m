% AverageByRegion
% Sarah West
% 1/23/23

function [parameters] = AverageByRegion(parameters)


    data = parameters.data; % 32 x 7 (nodes x mice)

    comparison = parameters.values{find(strcmp(parameters.keywords, 'comparison'))};
    comparisoni = parameters.values{find(strcmp(parameters.keywords, 'comparison_iterator'))};
    regions = fieldnames(parameters.regions);
    
    data_out = NaN(1, numel(regions),2);

    for regioni = 1: numel(regions)

        region = regions{regioni};

        % average inside region
        vals_inside = mean(data(parameters.regions.(region), :),1);
         
        
        % average across mice

        data_out(1, regioni, 1) = mean(vals_inside, 2);
        data_out(1, regioni, 2) = std(vals_inside, [], 2); 
        

%         vals(comparisoni).(region).avg_across_mice = mean(vals_inside, 2);
%         vals(comparisoni).(region).std_across_mice = std(vals_inside, [], 2); 
%         vals(comparisoni).comparison = comparison;
       

    end

end 