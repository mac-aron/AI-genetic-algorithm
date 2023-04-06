% returns two crossed chromosomes
function crossover = UniformCrossover(chromosome_1, chromosome_2)
    
    % set the swapping ability to set the threshold for swapping
    swapping_probability = 0.5;

    % give a probability to each allele
    allele_probability = zeros(1, length(chromosome_1));
    for i = 1:length(allele_probability)
        allele_probability(i) = rand;
    end
            
    % iterate through the genes of the chromosomes
    for j = 1:length(chromosome_1)
        
        % check if the random probability is larger than the given one
        if swapping_probability < allele_probability(j)
            
            % if yes, swap that allele
            temp = chromosome_1(j);
            chromosome_1(j) = chromosome_2(j);
            chromosome_2(j) = temp;
        end
    end
    crossover = [chromosome_1; chromosome_2];
end