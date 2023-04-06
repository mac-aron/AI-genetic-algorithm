% clear any pre-existing user data
clear all;
close all;

% read the food map
map = readmatrix('muir_world.txt');

%% user menu

fprintf("┌───────────────────────────────────────────────────┐\n");
fprintf("│Genetic Algorithms coursework by Aron Eggens (2022)│\n");
fprintf("└───────────────────────────────────────────────────┘\n\n");

fprintf("┌───────────────────────┐\n");
fprintf("│Choose selection method│\n");
fprintf("├──────────────────┬────┴─────────┬───────────────┐\n");
fprintf("│[1] Roulette-wheel│[2] Tournament│[3] Linear-rank│\n");
fprintf("└──────────────────┴──────────────┴───────────────┘\n");
a = input("");

fprintf("┌───────────────────────┐\n");
fprintf("│Choose crossover method│\n");
fprintf("├───────────┬───────────┤\n");
fprintf("│[1] Uniform│[2] K-Point│\n");
fprintf("└───────────┴───────────┘\n");
b = input("");

fprintf("┌──────────────────────┐\n");
fprintf("│Choose mutation method│\n");
fprintf("├────────────────────┬─┴───────────────┐\n");
fprintf("│[1] Random resetting│[2] Swap mutation│\n");
fprintf("└────────────────────┴─────────────────┘\n");
c = input("");

fprintf("┌────────────────────┐\n");
fprintf("│Running algorithm...│\n");
fprintf("└────────────────────┘\n");

% start clock
tic;

%% set options for selection, crossover and mutation methods

% [1] roulette-wheel selection [WORKS]
% [2] tournament selection [WORKS]
% [3] linear-rank selection [WORKS]
SELECTION_METHOD = a;
TOURNAMENT_SIZE = 10; % only for tournament selection
 
% [1] uniform crossover [WORKS]
% [2] k-point crossover [WORKS]
CROSSOVER_METHOD = b;
CROSSOVER_PROB = 0.8;

% [1] random-resseting mutation [WORKS]
% [2] swap mutation [WORKS]
MUTATION_METHOD = c;
MUTATION_PROB = 0.2;

% [1] elitism replacement strategy [WORKS]
% [2] random replacement strategy [WORKS]
% [3] generational replacement [WORKS]
REPLACEMENT_STRATEGY = 1;
ELITE_PERCENTAGE = 0.3; % only for elite replacement
NEW_POPULATION_SAMPLE = 2; % only for random replacement

%% set size and iteration macros

% number of chromosomes in the population
POPULATION_SIZE = 100;   

% chromosome size
CHROMOSOME_SIZE = 30; % do not change!

% set the nuber of iterations
ITER = 1000; % max 1000 in this coursework
last_index = ITER; % cut-off index, used for graphs and plots

% the threshold for the end condition of +/- fitness
END_THRESHOLD = 1;
END_ITERATION = 500; % number of previous iterations to check

%% generate population of chromosomes using value encoding

% ┌───────┬─────┬────────────────────────────────────────────────────┐
% │digit #│range│                    meaning                         │
% ├───────┼─────┼────────────────────────────────────────────────────┤
% │   1   │ 1-4 │the action the ant takes upon entering this state   │
% │       │     │                                                    │
% │       │     │[1] move forwards one cell                          │
% │       │     │[2] turn right ninety degrees without changing cells│
% │       │     │[3] turn left ninety degrees without changing cells │
% │       │     │[4] do nothing                                      │
% ├───────┼─────┼────────────────────────────────────────────────────┤
% │   2   │ 0-9 │if the ant is in this state and the sensor value is │
% │       │     │false (no food ahead) then the ant will transition  │
% │       │     │to the state with the unique identifier indicated by│
% │       │     │this digit                                          │
% ├───────┼─────┼────────────────────────────────────────────────────┤
% │   3   │ 0-9 │if the ant is in this state and the sensor value is │
% │       │     │true (no food ahead) then the ant will transition   │
% │       │     │to the state with the unique identifier indicated by│
% │       │     │this digit                                          │
% └───────┴─────┴────────────────────────────────────────────────────┘

% vector to store the fittest score of each generation
fitness_data = zeros(ITER, 1); 

% population size of POPULATION_SIZE
population = zeros(POPULATION_SIZE, CHROMOSOME_SIZE);

% for each chromosome in the population
for i = 1:POPULATION_SIZE

    % initialize the chromosome
	new_chromosome = zeros(1, CHROMOSOME_SIZE);
	
    % set three types of genes for all 10 states in that chromosome
    for j = 1:10
        
        % set a random digits for digit # 1
        digit_1 = randi(4, 1); % range 1-4
		new_chromosome((j-1)*3+1) = digit_1;
		
        % set a random digits for digit # 2
        digit_2 = randi(9, 1); % range 0-9
        new_chromosome((j-1)*3+2) = digit_2;

        % set a random digits for digit # 3
        digit_3 = randi(9, 1); % range 0-9
        new_chromosome((j-1)*3+3) = digit_3;

    end
    
    % add the chromosome to the population
	population(i, :) = new_chromosome;
end

% add an extra column for storing the fitness variable 
population = [population zeros(POPULATION_SIZE, 1)];


%% end conditions

%                ┌──────────┐
%                │iterations│◄────────────────────────────┐
%                └────┬─────┘                             │
%                     │                                   │
%                     ▼                                   │
% ┌─────────────────────────────────────────┐             │
% │check if the last END_ITERATIONS         │             │
% │have a fitness score of +/- END_THRESHOLD│             │
% └──────────────────┬──┬───────────────────┘             │
%                    │  │                               ┌─┴┐
%           ┌───┐    │  │     ┌──┐                      │no│
%      ┌────┤yes│◄───┘  └────►│no├──┐                   └──┘
%      │    └───┘             └──┘  │                     ▲
%      ▼                            ▼                     │
% ┌─────────┐ ┌───────────────────────────────────────┐   │
% │terminate│ │        iterations reached ITER        ├───┘
% └─────────┘ └──────────────────┬────────────────────┘
%                                │
%                        ┌───┐   │
%                     ┌──┤yes│◄──┘
%                     │  └───┘
%                     ▼
%                ┌─────────┐
%                │terminate│
%                └─────────┘

% [end condition 1] repeat ITER times each time generates a new population
% terminate when reaches ITER iterations
for k = 1:ITER

    % evaluate the fitness score
    for i = 1:POPULATION_SIZE
        % using the external method provided
        [fitness, trail] = simulate_ant(map, population(i, 1:30));

        % saving the fitness score in the last column in each chromosome
        population(i, 31) = fitness;
    end
    
    % sort chromosomomes by fitness
    population = sortrows(population, 31);   

    % save score of fittest in this generation k for plotting
    fitness_data(k, 1) = population(end, 31);
    
    % [end condition 2] find the average of each population 
    % terminate if the last END_ITERATION iterations had a value of average
    % +/- END_THRESHOLD 
    % this is reflected on the graph and the % value on the plot
    % see [MODIFICATION] notes at the end
    
    % if the average +/- 1 is the same for 300 generations, than terminate
    terminate = false(END_ITERATION,1);
    if(k > END_ITERATION)
        
        % take the last END_ITERATION fitness values
        latest_values = fitness_data(k-END_ITERATION:k,1);
        
        % find the mean of the latest fitness values
        latest_average = mean(latest_values);

        % set the upper and lower limit for the condition
        upper_bound = latest_average + END_THRESHOLD;
        lower_bound = latest_average - END_THRESHOLD;

        % check all fitness values if they fall within the limits
        for i = 1:length(latest_values)
            if (latest_values(i) >= lower_bound) && (latest_values(i) <= upper_bound)
                terminate(i) = true;
            end
        end
    end
    
    % if all values fall within the limit threshold, terminate
    if (terminate)
        last_index = k;
        break;
    end

    %% replacement strategies
    
    % [1] elitism replacement strategy
    %
    % This strategy involves keeping the best performing individuals from 
    % the current population and replacing the rest with new offspring. 
    % This ensures that the best performing individuals are always present 
    % in the population and have a chance to pass on their traits to the 
    % next generation.
    if (REPLACEMENT_STRATEGY == 1)
        % keep the best ELITE_PERCENTAGE of the population
        population_new(1:(ELITE_PERCENTAGE*POPULATION_SIZE),:) = population(POPULATION_SIZE-(0.3*POPULATION_SIZE-1):POPULATION_SIZE,1:30);
        population_new_index = (ELITE_PERCENTAGE*POPULATION_SIZE);
    
    % [2] random replacement strategy 
    % 
    % In random replacement, the children replace two randomly chosen 
    % individuals in the population.
    elseif (REPLACEMENT_STRATEGY == 2)
        % select two chromosome to be carried forward
        random_chromosome_indices = randperm(POPULATION_SIZE, NEW_POPULATION_SAMPLE);
        
        % add all indices to the new population
        for i = 1:length(random_chromosome_indices)
            population_new(i,:) = population(random_chromosome_indices(i),1:30);
        end
        
        % set new index
        population_new_index = NEW_POPULATION_SAMPLE; % maybe +1?

    % [3] generational replacement
    %
    % This strategy involves replacing the entire population with a new one 
    % at each generation. This can be useful when the population has become 
    % too diverse or when the performance of the individuals in the 
    % population has plateaued.
    elseif (REPLACEMENT_STRATEGY == 3)
        % create a new population for the next k+1 generation
        population_new = zeros(1,30); 
    
        % previous population is not carried forward to the new population
        population_new_index = 0;
    end

    %% generational loop
    while(population_new_index < POPULATION_SIZE)

        %% select methods

        % [1] roulette wheel selection method
        %
        % Roulette wheel selection is a method of selecting individuals 
        % from a population in a genetic algorithm (GA) to participate in 
        % the reproduction process. The idea behind roulette wheel 
        % selection is to assign a higher probability of selection to 
        % individuals with better fitness scores, in a way that is similar 
        % to linear-rank selection. However, in roulette wheel selection, 
        % the selection probabilities are assigned in a continuous manner, 
        % rather than being based on ranks.
        if(SELECTION_METHOD  == 1)

            % set the weights 
            weights = population(:,31)/sum(population(:,31));

            % get the index of two choices
            choice1 = RouletteWheelSelection(weights);
            choice2 = RouletteWheelSelection(weights);
    
        % [2] tournament selection method 
        %
        % Tournament selection is a method of selecting individuals from a 
        % population in a genetic algorithm (GA) to participate in the 
        % reproduction process. The idea behind tournament selection is to 
        % randomly select a small group of individuals (called a 
        % tournament) from the population, and then choose the individual 
        % with the best fitness score to participate in reproduction. This 
        % process is repeated until the desired number of individuals have 
        % been selected.
        elseif(SELECTION_METHOD == 2)

            % get the index of two choices
            choice1 = TournamentSelection(population, TOURNAMENT_SIZE);
            choice2 = TournamentSelection(population, TOURNAMENT_SIZE);
         
        % [3] linear-rank selection method
        %
        % Linear-rank selection is a method of selecting individuals from a 
        % population in a genetic algorithm (GA) to participate in the 
        % reproduction process. The idea behind linear-rank selection is 
        % to assign a higher probability of selection to individuals with 
        % better fitness scores. This can be done by ranking the 
        % individuals in the population according to their fitness scores, 
        % and then assigning a selection probability to each individual 
        % based on their rank.
        elseif(SELECTION_METHOD == 3)

            % get the index of two choices
            choice1 = LinearRankSelection(population);
            choice2 = LinearRankSelection(population);

        end
        
        temp_chromosome_1 = population(choice1,1:30);
        temp_chromosome_2 = population(choice2,1:30);

        %% crossover operators

        % [1] uniform crossover 
        %
        % Uniform crossover is a variation of crossover in a genetic 
        % algorithm that combines the genes of two parent solutions 
        % by randomly selecting genes from either parent with equal 
        % probability.
        if(CROSSOVER_METHOD == 1)

            % only occurs if crossover probability hits
            if (rand > CROSSOVER_PROB) 
                crossover = UniformCrossover(temp_chromosome_1, temp_chromosome_2);
                temp_chromosome_1 = crossover(1,:);
                temp_chromosome_2 = crossover(2,:);
            end 

        % [2] k-point crossover
        %
        % The k-point crossover is a variant of this operation that 
        % involves selecting k points in the parent solutions and swapping 
        % the segments between the points to create the offspring.
        %
        % The k-point crossover can be used to create a diverse set of 
        % offspring solutions that inherit characteristics from both 
        % parents, which can help the genetic algorithm to explore a 
        % wider range of the search space and potentially find better 
        % solutions.
        elseif(CROSSOVER_METHOD == 2)

            % only occurs if crossover probability hits
            if (rand > CROSSOVER_PROB)
                crossover = KPointCrossover(temp_chromosome_1, temp_chromosome_2);
                temp_chromosome_1 = crossover(1,:);
                temp_chromosome_2 = crossover(2,:);
            end 
        end
    
        %% mutation operators
    
        % [1] random resetting mutation
        %
        % Random resetting mutation is a variation of mutation in a genetic 
        % algorithm that randomly selects a gene in a solution and 
        % assigns it a new, randomly generated value. This can be useful 
        % for introducing new, randomly generated solutions into the 
        % population of solutions in the GA
        if(MUTATION_METHOD == 1)
            % only occurs if mutation probability hits
            if(rand > MUTATION_PROB) 
                temp_chromosome_1 = RandomResettingMutation(temp_chromosome_1); 
            end
            if(rand > MUTATION_PROB) 
                temp_chromosome_2 = RandomResettingMutation(temp_chromosome_2); 
            end
            
        % [2] swap mutation
        %
        % Swap mutation is a variation of mutation in a genetic algorithm 
        % that randomly selects two genes in a solution and swaps 
        % their values. This can be useful for introducing new solutions 
        % into the population of solutions in the GA by making small, 
        % local changes to existing solutions.
        elseif(MUTATION_METHOD == 2)
            % only occurs if mutation probability hits
            if(rand > MUTATION_PROB) 
                temp_chromosome_1 = SwapMutation(temp_chromosome_1); 
            end
            if(rand > MUTATION_PROB) 
                temp_chromosome_2 = SwapMutation(temp_chromosome_2); 
            end  
        end
    
        %% place the new chromosomes in the new population

        % increment the new population index and add temp_chromosome_1
        population_new_index = population_new_index + 1;
        population_new(population_new_index,:) = temp_chromosome_1;
    
        % increment the new population index and add temp_chromosome_2
        if (population_new_index < POPULATION_SIZE)
            population_new_index = population_new_index + 1;
            population_new(population_new_index,:) = temp_chromosome_2;
        end
        
    end
    
    %% set the newly created population as the default population
    population(:,1:30) = population_new;

end

% end clock
toc;

%% output a plot showing the fitness score of the most-fit ant in each generation
hf = figure(1); set(hf,'Color',[1 1 1]);
hp = plot(1:ITER,100*fitness_data/89,'r');
set(hp,'LineWidth',2);

axis([0 last_index-1 0 100]); grid on; % [MODIFICATION] set to cut the graph after early termination
xlabel('Generation number');
ylabel('Ant fitness [%]');
title('Ant fitness as a function of generation');

%% output a plot showing the trail of the most-fit ant in the final generation

% read the John Moir Trail (world)
filename_world = 'muir_world.txt';
world_grid = map;
%dlmread(filename_world,' ');

% display the John Moir Trail (world)
world_grid = rot90(rot90(rot90(world_grid)));
xmax = size(world_grid,2);
ymax = size(world_grid,1);
hf = figure(2); set(hf,'Color',[1 1 1]);

for y=1:ymax
    for x=1:xmax
        if(world_grid(x,y) == 1)
            h1 = plot(x,y,'sk');
            hold on
        end
    end
end
grid on

% display the fittest Individual trail
for k=1:size(trail,1)
    h2 = plot(trail(k,2),33-trail(k,1),'*m');
    hold on
end
axis([1 32 1 32])
title_str = sprintf('John Muri Trail - Hero Ant fitness %d%% in %d generations ',uint8(100*fitness_data(last_index, 1)/89), last_index); % [MODIFICATION] set to adjust the percentage value after early termination
title(title_str)
lh = legend([h1 h2],'Food cell','Ant movement');
set(lh,'Location','SouthEast');
movegui('south'); % [MODIFICATION] move the plot to the bottom of the screen