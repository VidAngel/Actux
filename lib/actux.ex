defmodule Actux do
  @moduledoc """
    This module contains a simple function that you can use to transmit logs or
    analytics for your Elixir applications to actus.

    ### Configuring

    You can set your host and namespace by configuring the :actux application.

    ```elixir
    config :actux,
      actus_host: System.get_env("ACTUS_HOST"),
      actus_namespace: :my_namespace
    ```

    If you do not configure the application, then the defaults will be:
    - actus_host: `"0.0.0.0"`
    - actus_namespace: `:event`
  """
  @default_host "0.0.0.0"
  @default_namespace :event

  def url(nil, table), do: url(Application.get_env(:actux, :actus_namespace, @default_namespace), table)
  def url(namespace, table) do
    Application.get_env(:actux, :actus_host, @default_host) <> "/#{namespace}/#{table}"
  end

  def push(namespace \\ nil, table, data) do
    case Tesla.post(
           url(namespace, table),
           Jason.encode!(data),
           [{"Content-type", "application/json"}]
         ) do
      {:ok, response} -> {:ok, response.status}
      {:error, reason} -> {:error, reason}
    end
  end

end
