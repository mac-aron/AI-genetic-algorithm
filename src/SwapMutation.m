function mutated_chromosome = SwapMutation(chromosome)

    gene_index1 = randi(length(chromosome));
    gene_index2 = randi(length(chromosome));

    % swap the values of the selected genes
    mutated_chromosome = chromosome;
    mutated_chromosome(gene_index1) = chromosome(gene_index2);
    mutated_chromosome(gene_index2) = chromosome(gene_index1);

end