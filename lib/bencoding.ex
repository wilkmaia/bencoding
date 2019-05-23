defmodule Bencoding do
  @moduledoc """
  Bencoding encoder/decoder module
  """

  def decode(string) do
    Bencoding.Decoder.decode(string)
  end

  def decode!(string) do
    { :ok, result } = Bencoding.Decoder.decode(string)

    result
  end
end
