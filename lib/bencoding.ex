defmodule Bencoding do
  @moduledoc """
  Bencoding encoder/decoder module
  """

  @spec decode(binary()) :: {:error, binary()} | {:ok, binary() | [binary() | integer() | map()] | integer() | map()}
  def decode(string) when is_binary(string) do
    Bencoding.Decoder.decode(string)
  end

  @spec decode!(binary()) :: binary() | [binary() | integer() | map()] | integer() | map()
  def decode!(string) when is_binary(string) do
    { :ok, result } = Bencoding.Decoder.decode(string)

    result
  end

  @spec encode(binary() | [binary() | integer() | map()] | integer() | map()) :: {:error, binary()} | {:ok, binary()}
  def encode(data), do: Bencoding.Encoder.encode(data)

  @spec encode!(binary() | [binary() | integer() | map()] | integer() | map()) :: binary()
  def encode!(data) do
    { :ok, result } = Bencoding.Encoder.encode(data)

    result
  end
end
