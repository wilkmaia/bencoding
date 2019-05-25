defmodule Bencoding do
  @moduledoc """
  Bencoding encoder/decoder module
  """

  @spec decode(binary()) :: {:error, binary()} | {:ok, any()}
  def decode(string) when is_binary(string) do
    Bencoding.Decoder.decode(string)
  end

  @spec decode!(binary()) :: any()
  def decode!(string) when is_binary(string) do
    { :ok, result } = Bencoding.Decoder.decode(string)

    result
  end
end
