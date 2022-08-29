defmodule Genetic do
  @moduledoc """
  Hyperparameter: population size (default: 100)
  """
  def run(problem, opts \\ []) do
    population = initialize(&problem.genotype/0)
    population |> evolve(problem, opts)
  end

  @doc """
  Models a single evolution
  """
  def evolve(population, problem, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)
    best = hd(population)
    IO.write("\rCurrent Best: #{best.fitness}")

    if problem.terminate?(population) do
      best
    else
      population
      |> select(opts)
      |> crossover(opts)
      |> mutation(opts)
      |> evolve(problem, opts)
    end
  end

  @doc """
  Returns a population respresented as a list of chromosomes
  """
  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    for _ <- 1..population_size, do: genotype.()
  end

  @doc """
  Sorts population based on fitness function
  """
  def evaluate(population, fitness_function, opts \\ []) do
    population
    |> Enum.map(
        fn chromosome ->
          fitness = fitness_function.(chromosome)
          age = chromosome.age + 1
          %Chromosome{chromosome | fitness: fitness, age: age}
        end
      )
    |> Enum.sort_by(fitness_function, &>=/2)
  end

  @doc """
  Returns an enumerable of tuples
  """
  def select(population, opts \\ []) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple(&1))
  end

  @doc """
  Genetic operator to take parent chromosomes, split the parents at the crossover
  point, create two chidren and prepend them to the population
  """
  def crossover(population, opts \\ []) do
    population
    |> Enum.reduce([],
        fn {p1, p2}, acc ->
          cx_point = :rand.uniform(length(p1.genes))
          {{h1, t1}, {h2, t2}} = {Enum.split(p1.genes, cx_point), Enum.split(p2.genes, cx_point)}
          {c1, c2} = {%Chromosome{genes: h1 ++ t2}, %Chromosome{genes: h2 ++ t1}}
          [c1 | [c2 | acc]]
        end
      )
  end

  @doc """
  Mutation prevents parents from becoming too similar before they crossover
  Shuffle the genes of chromosome which is selected with 0.05% probability
  """
  def mutation(population, opts \\ []) do
    population
    |> Enum.map(
        fn chromosome ->
          if :rand.uniform() < 0.05 do
            %Chromosome{genes: Enum.shuffle(chromosome.genes)}
          else
            chromosome
          end
        end
      )
  end
end
