% returns the index of the chosen chromosome
function choice = RouletteWheelSelection(weights)
    
accumulation = cumsum(weights);
    p = rand();
    chosen_index = -1;
    for index = 1 : length(accumulation)
        if (accumulation(index) > p)
            chosen_index = index;
            break;
        end
    end
choice = chosen_index;