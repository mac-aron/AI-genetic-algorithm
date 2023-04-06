# AI-genetic-algorithm
This project implements a genetic algorithm (GA) in Matlab in order to explore and experiment with a number of selection, mutation, crossover, and replacement strategies. The goal is to maximize the overall fitness score over a number of generations. After repeated measurements, the average fitness score is **>91%** in 667 generations (or less), but depends a lot on the startegies used, and macros set in `main.m`. 

## How to run?
1. Ensure you are running Matlab 2020a or later versions
2. Open `main.m`
3. Execute `run main.m` in the Matlab `Command Window`
4. Follow the CLI to set the parameters for the generational algorithm
5. Wait several seconds for the Muir map and the fitness score graph

**NOTE:** re-run the sript if the algorithm has a very low fitness score, this could be due to entering a peak/trough in the data

## Project description
In this project, a controller is evolved for a simulated ant. Each ant must survive on its own in a world represented by a 2D grid of cells by following trails of food. Each cell in the world either has a piece of food or is empty and the cells wrap-around (so, moving up when in the top row leaves the ant in the bottom row of the grid).

The ant’s position at any point in time can be specified by a cell location and a heading (north, south, east, or west). The ant always starts in the cell in the upper left corner, facing right (east). At the beginning of each time-step it gets one bit of sensory information: whether there is food in the cell in front of the cell it currently occupies (i.e., the cell it would move to if it moved forward). At each time-step it has one of four possible actions. It can move forward one cell; turn right ninety degrees without changing cells; turn left ninety degrees without changing cells; or do nothing. If an ant moves onto a food-cell, it consumes the food and the food disappears; when the ant leaves that cell, the cell is empty. The **fitness** of the ant is rated by counting how many food elements it consumes in 200 time-steps. (An ant that consumes 10 cells worth of food receives a fitness score of 10.)

For further details on the implementation, the finite state machine (FSM) controller, and the diagram of the Muir world (also below), see `spec.pdf`.

## Genetic algorithm
In terms of the algorithm implementation, the main task is to implement with Matlab a genetic algorithm that attempts to build a better ant through evolution. MATLAB's `ga` function **CANNOT BE USED**. 

The algorithm makes use of the following appropriate `selection`, `crossover`, `mutation`, and `replacement` operators, all of which are implemented without using any exisiting libraries. For each of the paramter values in each method I have carefully made the design decisions on how to implement the algorithm and what parameter values to use, and those can be set in the macros section in `main.m`.

### Selection
- **Roulette wheel selection** is a method to assign a higher probability of selection to
        individuals with better fitness scores, in a way that is similar
        to linear-rank selection. However, in roulette wheel selection,
        the selection probabilities are assigned in a continuous manner,
        rather than being based on ranks.
- **Tournament selection** is a method to
        randomly select a small group of individuals (called a
        tournament) from the population, and then choose the individual
        with the best fitness score to participate in reproduction. This
        process is repeated until the desired number of individuals have
        been selected.
- **Linear-rank selection** is a method to assign a higher probability of selection to individuals with
        better fitness scores. This can be done by ranking the
        individuals in the population according to their fitness scores,
        and then assigning a selection probability to each individual
        based on their rank.
 
 ### Crossover
- **Uniform crossover** is a variation of crossover in a genetic
        algorithm that combines the genes of two parent solutions
        by randomly selecting genes from either parent with equal
        probability.
- **K-point crossover** is a variant of this operation that
        involves selecting k points in the parent solutions and swapping
        the segments between the points to create the offspring.
        The k-point crossover can be used to create a diverse set of
        offspring solutions that inherit characteristics from both
        parents, which can help the genetic algorithm to explore a
        wider range of the search space and potentially find better
        solutions.

### Mutation
- **Swap mutation** is a variation of mutation in a genetic algorithm
        that randomly selects two genes in a solution and swaps
        their values. This can be useful for introducing new solutions
        into the population of solutions in the GA by making small,
        local changes to existing solutions.
- **Random resetting mutation** is a variation of mutation in a genetic
        algorithm that randomly selects a gene in a solution and
        assigns it a new, randomly generated value. This can be useful
        for introducing new, randomly generated solutions into the
        population of solutions in the GA.


### Replacement
- **Elitism replacement** strategy involves keeping the best performing individuals from
    the current population and replacing the rest with new offspring.
    This ensures that the best performing individuals are always present
    in the population and have a chance to pass on their traits to the
    next generation. The `default` startegy is elitism replacement, but can be set to a different startegy with `REPLACEMENT_STRATEGY` macro.
- **Random replacement**, here the children replace two randomly chosen individuals in the population.
- **Generational replacement** involves replacing the entire population with a new one 
    at each generation. This can be useful when the population has become 
    too diverse or when the performance of the individuals in the 
    population has plateaued.

### End conditions 
Two end conditions must be met, (1) repeat `ITER` times each time generates a new population, and terminate when reaches `ITER` iteration, and (2)  find the average of each population, and terminate if the last `END_ITERATION` iterations had a value of average +/- `END_THRESHOLD`.

```matlab
% graph from main.m
%
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
```
## Muir world
The ant environment (called the “John Muir” trail)  consists of a 32 by 32 grid containing 89 food cells. 

```
0 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 0 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1
0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0
0 0 0 1 0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0
0 0 0 1 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0
0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0
0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 1 0 0 1 1 1 1 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
```
