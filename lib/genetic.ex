defmodule Genetic do
  @moduledoc """
  Hyperparameter: population size (default: 100)
  """
  def run(fitness_function, genotype, max_fitness, opts \\ []) do
    population = initialize(genotype)
    population |> evolve(fitness_function, genotype, max_fitness, opts)
  end

  @doc """
  Models a single evolution
  """
  def evolve(population, fitness_function, genotype, max_fitness, opts \\ []) do
    population = evaluate(population, fitness_function, opts)
    best = hd(population)
    IO.write("\rCurrent Best: #{fitness_function.(best)}")

    if fitness_function.(best) == max_fitness do
      best
    else
      population
      |> select(opts)
      |> crossover(opts)
      |> mutation(opts)
      |> evolve(fitness_function, genotype, max_fitness, opts)
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
  def evaluate(population, fitness_func, opts \\ []) do
    population |> Enum.sort_by(fitness_func, &>/2)
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
    |> Enum.reduce(
      [],
      fn {p1, p2}, acc ->
        cx_point = :rand.uniform(length(p1))
        {{h1, t1}, {h2, t2}} = {Enum.split(p1, cx_point), Enum.split(p2, cx_point)}
        {c1, c2} = {h1 ++ t2, h2 ++ t1}
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
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < 0.05 do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
    end)
  end
end
