defmodule Bencoding.Decoder do
  @moduledoc """
  Bencoding's decoder module
  """

  def decode(string) do
    { :ok, result, _ } = string
    |> _get_bencode
    |> _decode

    { :ok, result }
  end

  defp _get_bencode(<< "i", data :: binary >>), do: { :integer, data }
  defp _get_bencode(<< "l", data :: binary >>), do: { :list, data }
  defp _get_bencode(<< "d", data :: binary >>), do: { :dictionary, data }
  defp _get_bencode(<< data :: binary >>), do: { :string, data }

  defp _decode({ :integer, data }), do: _do_decode_integer(data)
  defp _decode({ :list, data }), do: _do_decode_list(data, [])
  defp _decode({ :dictionary, data }), do: _do_decode_dictionary(data, %{})
  defp _decode({ :string, data }), do: _do_decode_string(data)

  defp _do_decode_integer(data = << "-0", _ :: binary >>), do: { :error, ~s/Malformed bencoding integer #{data}/ }
  defp _do_decode_integer(data) when is_binary(data) do
    { number, rest } = data
    |> String.graphemes
    |> Enum.reduce_while({ [], data }, fn
      "e", { acc, << _ :: binary-1, res :: binary >> } -> { :halt, { acc, res } }
      val, { acc, << _ :: binary-1, res :: binary >> } -> { :cont, { [val | acc], res } }
      end)

    number = number
    |> Enum.join
    |> String.to_integer

    { :ok, number, rest }
  end

  defp _do_decode_list(<< "e", rest :: binary >>, contents), do: { :ok, Enum.reverse(contents), rest }
  defp _do_decode_list(data, contents) when is_binary(data) do
    { :ok, element, rest } = data
    |> _get_bencode
    |> _decode

    _do_decode_list(rest, [element | contents])
  end

  defp _do_decode_dictionary(<< "e", rest :: binary >>, contents), do: { :ok, contents, rest }
  defp _do_decode_dictionary(data, contents) do
    { :ok, key, rest } = { :string, data }
    |> _decode

    { :ok, value, rest } = rest
    |> _get_bencode
    |> _decode

    _do_decode_dictionary(rest, Map.put(contents, key, value))
  end

  defp _do_decode_string(data) when is_binary(data) do
    [len, content] = String.split(data, ":", parts: 2)
    len = String.to_integer(len)

    if String.length(content) < len do
      { :error, ~s/Malformed bencoding string #{data}/ }
    else
      { :ok, String.slice(content, 0, len), String.slice(content, len, String.length(content)) }
    end
  end
end
