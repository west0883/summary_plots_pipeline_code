% AverageByRegion
% Sarah West
% 1/23/23

function [parameters] = AverageByRegion(parameters)


    data = parameters.data; % 32 x 7 (nodes x mice)

    comparison = parameters.values{find(strcmp(parameters.keywords, 'comparison'))};
    comparisoni = parameters.values{find(strcmp(parameters.keywords, 'comparison_iterator'))};
    regions = fieldnames(parameters.regions);
   
    
    % If not on null distributions
    if ~parameters.null_distribution_flag
        data_out = NaN(numel(regions), 1);
    
        for regioni = 1: numel(regions)
    
            region = regions{regioni};
    
            % average inside region
            vals_inside = mean(data(parameters.regions.(region), :),1);
             
            % average across mice
            data_out(regioni, 1) = mean(vals_inside, 2);
            %data_out(regioni, 2) = std(vals_inside, [], 2); 
        end

    % If on null distributions
    else
        data_out = NaN(numel(regions), size(data, 3));

        for regioni = 1: numel(regions)
    
            region = regions{regioni};
    
            % average inside region
            vals_inside = mean(data(parameters.regions.(region), :, :), 1);
             
            % average across mice
            data_out(regioni, :) = squeeze(mean(vals_inside, 2));
            %data_out(regioni, 2, :) = std(vals_inside, [], 2); 
        end
    end

    parameters.data_out = data_out;

end 