defmodule Bencoding.Encoder do
  @moduledoc """
  Bencoding's decoder module
  """

  @spec encode(binary() | [binary() | integer() | map()] | integer() | map()) :: {:ok | :error, binary()}
  def encode(data) do
    res = do_encode(data)

    if is_binary(res) do
      { :ok, res }
    else
      res
    end
  end

  defp do_encode(data) when is_binary(data), do: _do_encode_string(data)
  defp do_encode(data) when is_list(data), do: "l" <> _do_encode_list(data) <> "e"
  defp do_encode(data) when is_map(data) do
    try do
      "d" <> _do_encode_dictionary(data) <> "e"
    catch
      :error -> { :error, "Dictionary keys must be strings" }
    end
  end
  defp do_encode(data) when is_integer(data), do: "i" <> _do_encode_integer(data) <> "e"

  defp _do_encode_string(data) when is_binary(data) do
    str_len = String.length(data)
    "#{str_len}:#{data}"
  end
  defp _do_encode_string(_), do: throw(:error) # The only case this happens is when trying to encode a dictionary key that's not a string

  defp _do_encode_list([]), do: ""
  defp _do_encode_list([ head | tail ]), do: do_encode(head) <> "#{_do_encode_list(tail)}"

  defp _do_encode_dictionary(data) do
    data
    |> Map.to_list
    |> Enum.map(fn { key, value } -> "#{_do_encode_string(key)}#{do_encode(value)}" end)
    |> Enum.join
  end

  defp _do_encode_integer(data) do
    "#{data}"
  end
end
