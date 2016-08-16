require 'rubo_claus'

class DNA
  include RuboClaus

  def to_rna(dna='')
    dna.split(//).map { |char| transform(char) }.join('')
  end

  define_function :transform do
    clauses(
      clause(['G'], proc { 'C' }),
      clause(['C'], proc { 'G' }),
      clause(['T'], proc { 'A' }),
      clause(['A'], proc { 'U' })
    )
  end
end

###
### ELIXIR VERSION
###
#
# defmodule DNA do
#   @doc """
#   Transcribes a character list representing DNA nucleotides to RNA
#
#   ## Examples
#
#   iex> DNA.to_rna('ACTG')
#   'UGAC'
#   """
#   @spec to_rna([char]) :: [char]
#   def to_rna(dna) do
#     Enum.map dna, &transform/1
#   end
#
#   @spec transform(char) :: char
#   defp transform(?G), do: ?C
#   defp transform(?C), do: ?G
#   defp transform(?T), do: ?A
#   defp transform(?A), do: ?U
# end
