function mutated_chromosome = RandomResettingMutation(chromosome)
  
    lower_bound = 0;
    upper_bound = 9;
    
    % select a random gene in the chromosome
    gene_index = randi(length(chromosome));

    % assign the selected gene a new, randomly generated value
    mutated_chromosome = chromosome;
    mutated_chromosome(gene_index) = round(lower_bound + rand * (upper_bound - lower_bound));

end