% returns the index of the linear ranked selection
function choice = LinearRankSelection(population)

    population_size = length(population);

    % normalize the fitness values so that they sum up to 1
    weights = zeros(population_size, 1);
    for i = 1:population_size
        weights(i) = population(i,end)/sum(population(:,end));
    end

    % Assign a selection probability to each individual based on their normalized fitness value
    cummulative_probabilities = cumsum(weights); 
    
    % generate a random number between 0 and 1
    r = rand();

    for j = 1:population_size
        if r < cummulative_probabilities(j)
            % select individual j for reproduction
            choice = j;
            break;
        end
    end