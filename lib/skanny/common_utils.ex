defmodule Skanny.CommonUtils do
  @moduledoc """
  Common utils used across the app
  """

  @spec generate_random_id() :: String.t()
  def generate_random_id(), do: :crypto.strong_rand_bytes(5) |> Base.url_encode64(padding: false)
end
