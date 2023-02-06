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

       

        vals_inside_all = NaN(numel(regions), numel(parameters.mice_all));
 
        data_out = NaN(numel(regions), 2);
    
        for regioni = 1: numel(regions)
    
            region = regions{regioni};
    
            % average inside region
            vals_inside = mean(data(parameters.regions.(region), :),1);

            % insert mouse 1100 as NaNs
            if numel(vals_inside) ~= numel(parameters.mice_all)
               vals_inside = [vals_inside(1:3) NaN vals_inside(4:end)];
            end 
                
            vals_inside_all(regioni, :) = vals_inside;
            % average across mice
            data_out(regioni, 1) = mean(vals_inside, 2, 'omitnan');
            data_out(regioni, 2) = std(vals_inside, [], 2, 'omitnan'); 

        end
        parameters.all_mice = vals_inside_all;
        parameters.data_out = data_out;
    % If on null distributions
    else
      
        data_out = NaN(numel(regions), size(data, 3), 2);
        vals_inside_all = NaN(numel(regions), numel(parameters.mice_all), size(data, 3));

        for regioni = 1: numel(regions)
    
            region = regions{regioni};
    
            % average inside region
            vals_inside = mean(data(parameters.regions.(region), :, :), 1);
             % insert mouse 1100 as NaNs
            if size(vals_inside, 2) ~= numel(parameters.mice_all)
               vals_inside = cat(2, vals_inside(:,1:3, :), NaN(1,1, size(data,3)), vals_inside(:, 4:end, :));
            end 
            vals_inside_all(regioni, :, :) = vals_inside;
             
            % average across mice
            data_out(regioni, :, 1) = squeeze(mean(vals_inside, 2, 'omitnan'));
            data_out(regioni, :, 2) = squeeze(std(vals_inside, [], 2, 'omitnan')); 
        end
    end
    parameters.all_mice = vals_inside_all;
    parameters.data_out = data_out;

end 