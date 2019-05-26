defmodule BencodingTest do
  use ExUnit.Case
  doctest Bencoding

  describe "public api" do
    test "on success" do
      assert Bencoding.decode("d5:valid4:datae") === { :ok, %{ "valid" => "data" } }
      assert Bencoding.decode!("d5:valid4:datae") === %{ "valid" => "data" }
      assert Bencoding.decode("l5:valid4:datae") === { :ok, [ "valid", "data" ] }
      assert Bencoding.decode!("l5:valid4:datae") === [ "valid", "data" ]

      assert Bencoding.encode("spam") === { :ok, "4:spam" }
      assert Bencoding.encode!("spam") === "4:spam"
      assert Bencoding.encode(42) === { :ok, "i42e" }
      assert Bencoding.encode!(42) === "i42e"
      assert Bencoding.encode(%{ "key" => "value" }) === { :ok, "d3:key5:valuee" }
      assert Bencoding.encode!(%{ "key" => "value" }) === "d3:key5:valuee"
      assert Bencoding.encode([1, 2, 3]) === { :ok, "li1ei2ei3ee" }
      assert Bencoding.encode!([1, 2, 3]) === "li1ei2ei3ee"
    end

    test "on error" do
      assert Bencoding.decode("di3e4:datae") === { :error, "Malformed bencoding string \"di3e4:datae\"" }
      assert Bencoding.decode("d3:key5:value5:key_ble") === { :error, "Malformed bencoding string \"d3:key5:value5:key_ble\"" }

      assert Bencoding.encode(%{ [] => "invalid!" }) === { :error, "Dictionary keys must be strings" }
    end
  end

  describe "when decoding bencoding strings" do
    test "with valid values" do
      assert Bencoding.decode!("5:valid") === "valid"
      assert Bencoding.decode!("2:valid") === "va" # Since there is no string delimiter, can we say this is invalid?
      assert Bencoding.decode!("0:") === ""
    end

    test "with invalid values" do
      assert Bencoding.decode("10:invalid") === { :error, "Malformed bencoding string \"10:invalid\"" }
    end
  end

  describe "when decoding bencoding integers" do
    test "with valid values" do
      assert Bencoding.decode!("i3e") === 3
      assert Bencoding.decode!("i-1e") === -1
      assert Bencoding.decode!("i0e") === 0
      assert Bencoding.decode!("i999999999999999999e") === 999999999999999999
    end

    test "with invalid values" do
      assert Bencoding.decode("i00e") === { :error, "Malformed bencoding string \"i00e\"" }
      assert Bencoding.decode("i-0e") === { :error, "Malformed bencoding string \"i-0e\"" }
    end
  end

  describe "when decoding bencoding lists" do
    test "with valid values" do
      assert Bencoding.decode!("li3ee") === [3]
      assert Bencoding.decode!("le") === []
      assert Bencoding.decode!("ldee") === [%{}]
      assert Bencoding.decode!("l4:spame") === ["spam"]
    end

    test "with invalid values" do
      assert Bencoding.decode("li0e") === { :error, "Malformed bencoding string \"li0e\"" }
      assert Bencoding.decode("l") === { :error, "Malformed bencoding string \"l\"" }
    end
  end

  describe "when decoding bencoding dictionaries" do
    test "with valid values" do
      assert Bencoding.decode!("d3:keyi3ee") === %{ "key" => 3 }
      assert Bencoding.decode!("de") === %{}
      assert Bencoding.decode!("d3:keydee") === %{ "key" => %{} }
    end

    test "with invalid values" do
      assert Bencoding.decode("di0e5:valuee") === { :error, "Malformed bencoding string \"di0e5:valuee\"" }
      assert Bencoding.decode("d3:key5:value") === { :error, "Malformed bencoding string \"d3:key5:value\"" }
      assert Bencoding.decode("d") === { :error, "Malformed bencoding string \"d\"" }
    end
  end

  describe "when encoding" do
    test "integers" do
      assert Bencoding.encode!(0) === "i0e"
      assert Bencoding.encode!(-0) === "i0e"
      assert Bencoding.encode!(-1) === "i-1e"
      assert Bencoding.encode!(999999999999999999) === "i999999999999999999e"
    end

    test "strings" do
      assert Bencoding.encode!("test") === "4:test"
      assert Bencoding.encode!("This is a rather long string") === "28:This is a rather long string"
    end

    test "lists" do
      assert Bencoding.encode!([%{ "key" => "value" }, "x", 5]) === "ld3:key5:valuee1:xi5ee"
    end

    test "dictionaries" do
      assert Bencoding.encode!(%{ "key" => ["value"] }) === "d3:keyl5:valueee"
      assert Bencoding.encode!(%{ "z" => 0, "x" => 1, "a2" => 2, "a1" => 3 }) === "d2:a1i3e2:a2i2e1:xi1e1:zi0ee" # Sorted keys
      assert Bencoding.encode(%{ [] => "invalid!" }) === { :error, "Dictionary keys must be strings" }
      assert Bencoding.encode(%{ 1 => "invalid!" }) === { :error, "Dictionary keys must be strings" }
      assert Bencoding.encode(%{ %{} => "invalid!" }) === { :error, "Dictionary keys must be strings" }
    end
  end
end
