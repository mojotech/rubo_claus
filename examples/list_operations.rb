require 'rubo_claus'

class ListOps
  include RuboClaus

  define_function :count do
    clauses(
      clause([Array], proc { |array| count(array, 0) }),
      clause([[], Fixnum], proc { |_array, sum| sum }),
      clause([[:any, :tail], Fixnum], proc { |_head, tail, sum| count(tail, sum + 1) })
    )
  end

  # The Ruby way to implement count recursively
  def plain_ruby_count(array, sum=0)
    return sum if array == []
    a, *b = array
    plain_ruby_count(b, sum + 1)
  end
end

###
### ELIXIR VERSION
###
# defmodule ListOps do
#   @moduledoc """
#   Implements some common list operations by hand
#   """
#   @spec count(list) :: non_neg_integer
#   def count(l), do: l |> count(0)
#   def count([], sum), do: sum
#   def count([_|t], sum), do: count(t, sum + 1)
# end
