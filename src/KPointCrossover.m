% returns two crossed chromosomes
function crossover = KPointCrossover (chromosome_1, chromosome_2)
    
    % select a random k-point for the crossover
    kpoint = randi([1,29]);
    
    % perform the crossover
    temp = [chromosome_1(1:kpoint) chromosome_2(kpoint+1:end)];
    chromosome_2 = [chromosome_2(1:kpoint) chromosome_1(kpoint+1:end)];
    chromosome_1 = temp;
    
    % return the crossover'd chromosomes
    crossover = [chromosome_1; chromosome_2];

end
