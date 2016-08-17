require 'rubo_claus'

class RunLengthEncoder
  include RuboClaus

  def encode(str)
    encoder str.split(//), ''
  end

  define_function :encoder do
    clauses(
      clause([[], String], proc { |_arr, encoded| encoded }),
      clause([Array, String], proc do |arr, encoded|
        encoder(arr, encoded, 1)
      end),
      clause([Array, String, Fixnum], proc do |arr, encoded, count|
        h, *t = arr
        if h == t[0]
          encoder(t, encoded, count + 1)
        else
          encoder(t, encoded + "#{count}#{h}")
        end
      end)
    )
  end
end

###
### ELIXIR VERSION
###
#
# defmodule RunLengthEncoder do
#   @doc """
#   Generates a string where consecutive elements are represented as a data value and count.
#   "HORSE" => "1H1O1R1S1E"
#   For this example, assume all input are strings, that are all uppercase letters.
#   It should also be able to reconstruct the data into its original form.
#   "1H1O1R1S1E" => "HORSE"
#   """
#   @spec encode(String.t) :: String.t
#   def encode(string) do
#     encoder String.codepoints(string), ""
#   end
#
#   @spec encoder([String.t], String.t) :: String.t
#   defp encoder([], encoded), do: encoded
#   defp encoder([h | t], encoded), do: encoder([h | t], encoded, 1)
#
#   @spec encoder([String.t], String.t, integer()) :: String.t
#   defp encoder([h | t], encoded, count) do
#     cond do
#       Enum.at(t, 0) == h -> encoder(t, encoded, count + 1)
#       true -> encoder(t, encoded <> "#{count}#{h}")
#     end
#   end
#
#   @spec decode(String.t) :: String.t
#   def decode(string) do
#     Regex.scan(~r/\\d+[A-Z]/, string) |> List.flatten |> decoder
#   end
#
#   @spec decoder([String.t]) :: String.t
#   defp decoder(chars) do
#     Enum.reduce chars, "", &(&2 <> format_string(String.split_at(&1, -1)))
#   end
#
#   @spec format_string(String.t) :: String.t
#   defp format_string({1, str}), do: str
#   defp format_string({cnt, str}), do: String.duplicate(str, String.to_integer(cnt))
# end
