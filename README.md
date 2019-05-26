# Bencoding

[![CircleCI](https://circleci.com/gh/wilkmaia/bencoding/tree/master.svg?style=svg)](https://circleci.com/gh/wilkmaia/bencoding/tree/master)

_Bencoding_ is a [bencoding](https://wiki.theory.org/index.php/BitTorrentSpecification#Bencoding) library written in Elixir as part of developing an elixir BitTorrent.

This is a learning project and should not be used for anyone that expects quality in downloading or serving content over the BitTorrent protocol.

## Installation

Simply add the bencoding entry to your `mix.exs` file:

```elixir
def deps do
  [
    {:bencoding, git: "https://github.com/wilkmaia/bencoding.git", tag: "v0.1.1"}
  ]
end
```

Check available releases on the [releases](https://github.com/wilkmaia/bencoding/releases) page.

## Usage

### Decoding Bencoding Strings

The `Bencoding.decode/1` function is responsible for decoding bencoding-encoded data into elixir data. Successfull decodings return a tuple with an `:ok` atom and the decoded data

```
iex> Bencoding.decode("i3e")
{:ok, 3}
iex> Bencoding.decode("le")
{:ok, []}
iex> Bencoding.decode("de")
{:ok, %{}}
iex> Bencoding.decode("4:spam")
{:ok, "spam"}
```

If any error happens on decoding, the return value will be `{:error, <Error message>}`

```
iex> Bencoding.decode("d")
{:error, "Malformed bencoding string \"d\""}
iex> Bencoding.decode("i3ee")
{:error, "Malformed bencoding string \"i3ee\""}
iex> Bencoding.decode("ie")
{:error, "Malformed bencoding string \"ie\""}
```

### Encoding Data

To encode elixir data into bencoding-encoded data, the `Bencoding.encode/1` function should be used. Upon success it returns a tuple with `:ok` and the encoded string.

```
iex> Bencoding.encode(3)
{:ok, "i3e"}
iex> Bencoding.encode([])
{:ok, "le"}
iex> Bencoding.encode(%{})
{:ok, "de"}
iex> Bencoding.encode("spam")
{:ok, "4:spam"}
```

If an error occurs during encoding, a tuple with `:error` and an error message is returned instead.

```
iex> Bencoding.encode(%{1 => "invalid"}) 
{:error, "Dictionary keys must be strings"}
```