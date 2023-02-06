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

% *** MAKE SURE THESE ARE THE PRE-RENUMBERING VALUES***
parameters.regions.M2 = 1:6; 
parameters.regions.antLatM2 = 1:2;
parameters.regions.remM2 = 3:6;
parameters.regions.M1 = 7:10;
parameters.regions.latM1 = 7:8;
parameters.regions.medM1 = 9:10;
parameters.regions.S1 = 11:14;
parameters.regions.LP = 17:20;
parameters.regions.MV = 21:28;
parameters.regions.Rs = 29:32;

% renumber the regions 
load('Y:\Sarah\Analysis\Experiments\Random Motorized Treadmill\node_renumbering.mat')
parameters.node_renumbering = node_renumbering;
regions = fieldnames(parameters.regions);
for i = 1:numel(regions)
    region = regions{i};
    parameters.regions.(region) = node_renumbering(parameters.regions.(region), 2);
end
clear node_renumbering regions region i 

%% categoricals
% average within region
% average across animals

parameters.null_distribution_flag = false; 

for categoryi = 1:numel(parameters.loop_variables.categories)
    category = parameters.loop_variables.categories{categoryi};

    if isfield(parameters, 'loop_list')
    parameters = rmfield(parameters,'loop_list');
    end
    
    % Iterators
    parameters.loop_list.iterators = {
                   'comparison', {['loop_variables.comparisons_categorical.' category '(:).name']}, 'comparison_iterator' ;    
                   };
    % Inputs
    if strcmp(category, 'normal')
    parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'PLSR\results\level 2 categorical\Ipsa Contra\'], 'comparison', '\'};
    else
        parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'PLSR Warning Periods\results\level 2 categorical\'], 'comparison', '\'};
    end
    
    parameters.loop_list.things_to_load.data.filename= {'average_by_nodes_Cov.mat'};
    parameters.loop_list.things_to_load.data.variable= {'average_by_nodes'}; 
    parameters.loop_list.things_to_load.data.level = 'comparison';
    
    % Outputs
    parameters.loop_list.things_to_save.data_out.dir = {[parameters.dir_exper 'figure creation\summary plots\means by region\'], 'comparison', '\'};
    parameters.loop_list.things_to_save.data_out.filename= {'average_by_region.mat'};
    parameters.loop_list.things_to_save.data_out.variable= {'average_by_region'}; 
    parameters.loop_list.things_to_save.data_out.level = 'comparison';
    
    RunAnalysis({@AverageByRegion}, parameters);
end 

%% categorical, run on null distributions 

parameters.null_distribution_flag = true;
for categoryi = 1:numel(parameters.loop_variables.categories)
    category = parameters.loop_variables.categories{categoryi};

    if isfield(parameters, 'loop_list')
    parameters = rmfield(parameters,'loop_list');
    end
    
    % Iterators
    parameters.loop_list.iterators = {
                   'comparison', {['loop_variables.comparisons_categorical.' category '(:).name']}, 'comparison_iterator' ;    
                   };
    % Inputs
    if strcmp(category, 'normal')
    parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'PLSR\results\level 2 categorical\Ipsa Contra\'], 'comparison', '\'};
    else
        parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'PLSR Warning Periods\results\level 2 categorical\'], 'comparison', '\'};
    end
    
    parameters.loop_list.things_to_load.data.filename= {'average_by_nodes_randomPermutations_Cov.mat'};
    parameters.loop_list.things_to_load.data.variable= {'average_by_nodes'}; 
    parameters.loop_list.things_to_load.data.level = 'comparison';
    
    % Outputs
    parameters.loop_list.things_to_save.data_out.dir = {[parameters.dir_exper 'figure creation\summary plots\means by region\'], 'comparison', '\'};
    parameters.loop_list.things_to_save.data_out.filename= {'average_by_region_randomPermutations.mat'};
    parameters.loop_list.things_to_save.data_out.variable= {'average_by_region'}; 
    parameters.loop_list.things_to_save.data_out.level = 'comparison';
    
    RunAnalysis({@AverageByRegion}, parameters);
end 

%% test significance based on null distrubution 

if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

% Iterators
parameters.loop_list.iterators = {
               'comparison', {['loop_variables.comparisons_categorical_both(:).name']}, 'comparison_iterator' ;    
               };

parameters.useBootstrapping = false;
parameters.useNormalDistribution = true;
parameters.useFDR = true; 
parameters.shufflesDim = 2; 
parameters.alphaValue = 0.05;
parameters.twoTailed = true;

% Inputs
% data 
parameters.loop_list.things_to_load.test_values.dir = {[parameters.dir_exper 'figure creation\summary plots\means by region\'], 'comparison', '\'};
parameters.loop_list.things_to_load.test_values.filename= {'average_by_region.mat'};
parameters.loop_list.things_to_load.test_values.variable= {'average_by_region'}; 
parameters.loop_list.things_to_load.test_values.level = 'comparison';

% null distributions  
parameters.loop_list.things_to_load.null_distribution.dir = {[parameters.dir_exper 'figure creation\summary plots\means by region\'], 'comparison', '\'};
parameters.loop_list.things_to_load.null_distribution.filename= {'average_by_region_randomPermutations.mat'};
parameters.loop_list.things_to_load.null_distribution.variable= {'average_by_region'}; 
parameters.loop_list.things_to_load.null_distribution.level = 'comparison';

% Outputs
parameters.loop_list.things_to_save.significance.dir = {[parameters.dir_exper 'figure creation\summary plots\means by region\'], 'comparison', '\'};
parameters.loop_list.things_to_save.significance.filename= {'average_by_region_significance.mat'};
parameters.loop_list.things_to_save.significance.variable= {'significance'}; 
parameters.loop_list.things_to_save.significance.level = 'comparison';

RunAnalysis({@SignificanceCalculation}, parameters);

%% group together for putting into Prism

parameters.loop_variables.figure_types = {'adjacent', 'direct', 'prepost'};

comparisons.adjacent = {
    'motorized_restvsstart_categorical';
    'motorized_fstartvsrest_categorical';
    'motorized_restvswalk';
    'motorized_restvsstop_categorical';
    'spontaneous_restvsstart_categorical';
    'spontaneous_restvswalk';
    'spontaneous_restvstop_categorical';
    };
  comparisons.direct = {
    'rest_motorizedvsspon_categorical';
    'start_motorizedvsspon_categorical';
    'walk_motorizedvsspon_categorical';
    'stop_motorizedvsspon_categorical';
    };
 comparisons.prepost = {
    'wstartvswmaint';
    'prewalkvsrest';
    'motorized_restvsfinishedstop_categorical';
    'spontaneous_restvsfinishedstop_categorical'
    };

% get out all comparison info
for i = 1:numel(parameters.loop_variables.figure_types)
    
    figure_type = parameters.loop_variables.figure_types{i};

    for ii = 1:numel(comparisons.(figure_type))
        comparison = comparisons.(figure_type){ii};

        % find that comparison in comparisons_categorical_both
        index = find(strcmp({parameters.comparisons_categorical_both(:).name}, comparison));
        parameters.comparisons.(figure_type)(ii, 1) = parameters.comparisons_categorical_both(index);
       
    end
end 
parameters.loop_variables.comparisons = parameters.comparisons;

clear figure_type index i ii comparison comparisons;

%%
if isfield(parameters, 'loop_list')
parameters = rmfield(parameters,'loop_list');
end

% Iterators
parameters.loop_list.iterators = {
               'figure_type', {'loop_variables.figure_types'}, 'figure_type_iterator'; 
               'comparison', {'loop_variables.comparisons.', 'figure_type', '(:).name'}, 'comparison_iterator' ;    
               };

parameters.evaluation_instructions = {{'multiplier = parameters.comparisongit ss.', 'figure_type', '(', 'comparison_iterator', ').plotMultiplier;'...
                                      'data_evaluated = parameters.data * multiplier;'}};
parameters.concatDim = 2;
parameters.concatenation_level = 'comparison';

% Inputs
parameters.loop_list.things_to_load.data.dir = {[parameters.dir_exper 'figure creation\summary plots\means by region\'], 'comparison', '\'};
parameters.loop_list.things_to_load.data.filename= {'average_by_region.mat'};
parameters.loop_list.things_to_load.data.variable= {'average_by_region'}; 
parameters.loop_list.things_to_load.data.level = 'comparison';

% Outputs
parameters.loop_list.things_to_save.concatenated_data.dir = {[parameters.dir_exper 'figure creation\summary plots\means by region concatenated\']};
parameters.loop_list.things_to_save.concatenated_data.filename= {'figure_type', '.mat'};
parameters.loop_list.things_to_save.concatenated_data.variable= {'average_by_region'}; 
parameters.loop_list.things_to_save.concatenated_data.level = 'figure_type';

parameters.loop_list.things_to_rename = {{'data_evaluated', 'data'}};

RunAnalysis({@EvaluateOnData, @ConcatenateData}, parameters);