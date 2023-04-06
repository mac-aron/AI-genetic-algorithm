% returns the index of the tournament winner
function choice = TournamentSelection(population, tournament_size)
    
    population_size = length(population);
    % randomly select a subset of individuals to participate in the tournament
    contestants = randperm(population_size, tournament_size);
    
    % evaluate the fitness of each individual in the tournament
    fitness_values = zeros(tournament_size, 1);
    for i = 1:tournament_size
        fitness_values(i,1) = population(contestants(i),end);
    end
    
    % select the top performer from the sorted list
    [~, index] = max(fitness_values);
    
choice = contestants(index);