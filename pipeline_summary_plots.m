% pipeline_summary_plots.m
% Sarah West
% 1/23/23

%% Initial Setup  
% Put all needed paramters in a structure called "parameters", which you
% can then easily feed into your functions. 
% Use correlations, Fisher transformed, mean removed within mice (mean
% removed for at least the cases when you aren't using mice as response
% variables).

clear all; 

% Create the experiment name.
parameters.experiment_name='Random Motorized Treadmill';

% Output directory name bases
parameters.dir_base='Y:\Sarah\Analysis\Experiments\';
parameters.dir_exper=[parameters.dir_base parameters.experiment_name '\']; 

% Load mice_all, pass into parameters structure
load([parameters.dir_exper '\mice_all.mat']);
parameters.mice_all = mice_all;

% ****Change here if there are specific mice, days, and/or stacks you want to work with**** 
parameters.mice_all = parameters.mice_all;

% Other parameters
parameters.digitNumber = 2;
parameters.yDim = 256;
parameters.xDim = 256;
parameters.number_of_sources = 32; 
parameters.indices = find(tril(ones(parameters.number_of_sources), -1));

% normal vs Warning periods, comparison types
parameters.loop_variables.categories = {'normal', 'warningPeriods'};
parameters.loop_variables.comparison_types = {'categorical', 'continuous'};

% Load comparisons
% normal vs warning period 
for i = 1:numel(parameters.loop_variables.categories)
    category = parameters.loop_variables.categories{i};
    if strcmp(category, 'normal')
        name = 'level1'; 
    else 
        name = category;
    end
    % categorical vs continuous
    for typei = 1:numel(parameters.loop_variables.comparison_types)
        type = parameters.loop_variables.comparison_types{typei};
        load([parameters.dir_exper 'PLSR\comparisons_' name '_' type '.mat']);
        parameters.(['comparisons_' type]).(category) = comparisons;
        parameters.loop_variables.(['comparisons_' type]).(category) = parameters.(['comparisons_' type]).(category);
    end
end

clear comparisons name i type typei;

parameters.comparisons_categorical_both = [parameters.comparisons_categorical.normal parameters.comparisons_categorical.warningPeriods];
parameters.comparisons_continuous_both = [parameters.comparisons_continuous.normal parameters.comparisons_continuous.warningPeriods];

% Names of all continuous variables.
parameters.continuous_variable_names = {'speed', 'accel', 'duration', 'pupil_diameter'};

% Put relevant variables into loop_variables.
parameters.loop_variables.mice_all = parameters.mice_all;
parameters.loop_variables.conditions = {'motorized'; 'spontaneous'};
parameters.loop_variables.data_type = {'corrs'; 'fluors'};
parameters.loop_variables.comparisons_categorical_both = parameters.comparisons_categorical_both;
parameters.loop_variables.comparisons_continuous_both = parameters.comparisons_continuous_both;
parameters.average_and_std_together = false;

parameters.regions.antM2 = 1:4;
parameters.regions.postM2 = 5:6;
parameters.regions.M1 = 7:10;

%
%% rest vs each
% average within region
% average across animals
parameters.loop_variables.comparisons_base = {'_restvsstart_categorical';
               '_restvswalk';
               '_restvsstop_categorical';
               };

if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

% Iterators
parameters.loop_list.iterators = {
               'comparison', {'loop_variables.comparisons_base.' category '(:).name'}, 'comparison_iterator' ;    
               };
% Inputs
parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'PLSR\results\level 2 categorical\Ipsa Contra\'], 'comparison', '\'};
parameters.loop_list.things_to_load.data.filename= {'average_by_nodes_Cov.mat'};
parameters.loop_list.things_to_load.data.variable= {'average_by_nodes'}; 
parameters.loop_list.things_to_load.data.level = 'comparison';

% Outputs
 
  columns = {'antM2', 'postM2', 'M1'};    
  T = table('VariableNames',columns);

%% motorized vs spon
comparisons_base = {'rest';
               'start';
               'walk';
               'stop';
               };

