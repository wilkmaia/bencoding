defmodule BencodingTest do
  use ExUnit.Case
  doctest Bencoding

  describe "public api" do
    test "on success" do
      assert Bencoding.decode("d5:valid4:datae") === { :ok, %{ "valid" => "data" } }
      assert Bencoding.decode("l5:valid4:datae") === { :ok, [ "valid", "data" ] }
    end

    test "on error" do
      assert Bencoding.decode("di3e4:datae") === { :error, "Malformed bencoding string \"di3e4:datae\"" }
      assert Bencoding.decode("d3:key5:value5:key_ble") === { :error, "Malformed bencoding string \"d3:key5:value5:key_ble\"" }
    end
  end

  describe "when decoding bencoding strings" do
    test "with valid values" do
      assert Bencoding.decode("5:valid") === { :ok, "valid" }
      assert Bencoding.decode("2:valid") === { :ok, "va" } # Since there is no string delimiter, can we say this is invalid?
      assert Bencoding.decode("0:") === { :ok, "" }
    end

    test "with invalid values" do
      assert Bencoding.decode("10:invalid") === { :error, "Malformed bencoding string \"10:invalid\"" }
    end
  end

  describe "when decoding bencoding integers" do
    test "with valid values" do
      assert Bencoding.decode("i3e") === { :ok, 3 }
      assert Bencoding.decode("i-1e") === { :ok, -1 }
      assert Bencoding.decode("i0e") === { :ok, 0 }
      assert Bencoding.decode("i999999999999999999e") === { :ok, 999999999999999999 }
    end

    test "with invalid values" do
      assert Bencoding.decode("i00e") === { :error, "Malformed bencoding string \"i00e\"" }
      assert Bencoding.decode("i-0e") === { :error, "Malformed bencoding string \"i-0e\"" }
    end
  end

  describe "when decoding bencoding lists" do
    test "with valid values" do
      assert Bencoding.decode("li3ee") === { :ok, [3] }
      assert Bencoding.decode("le") === { :ok, [] }
      assert Bencoding.decode("ldee") === { :ok, [%{}] }
      assert Bencoding.decode("l4:spame") === { :ok, ["spam"] }
    end

    test "with invalid values" do
      assert Bencoding.decode("li0e") === { :error, "Malformed bencoding string \"li0e\"" }
      assert Bencoding.decode("l") === { :error, "Malformed bencoding string \"l\"" }
    end
  end

  describe "when decoding bencoding dictionaries" do
    test "with valid values" do
      assert Bencoding.decode("d3:keyi3ee") === { :ok, %{ "key" => 3 } }
      assert Bencoding.decode("de") === { :ok, %{} }
      assert Bencoding.decode("d3:keydee") === { :ok, %{ "key" => %{} } }
    end

    test "with invalid values" do
      assert Bencoding.decode("di0e5:valuee") === { :error, "Malformed bencoding string \"di0e5:valuee\"" }
      assert Bencoding.decode("d3:key5:value") === { :error, "Malformed bencoding string \"d3:key5:value\"" }
      assert Bencoding.decode("d") === { :error, "Malformed bencoding string \"d\"" }
    end
  end
end
