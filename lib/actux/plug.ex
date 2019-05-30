defmodule Actux.Plug do
  @moduledoc """
  A plug for logging request information
  ## Options
    * `:namespace` - The actus namespace, overrides application configuration.
    * `:table` - The table to log to. Default is `"requests"`.
  """

  require Logger
  alias Plug.Conn

  @behaviour Plug

  def init(opts) do
    Keyword.merge([table: :requests], opts)
  end

  def call(conn, opts) do
    request_start = System.monotonic_time()

    Conn.register_before_send(
      conn,
      fn conn ->
        response_time = response_time(request_start)
        Logger.info "Sending Request data to Actus",
                    namespace: Keyword.get(opts, :namespace),
                    table: Keyword.get(opts, :table),
                    request_attrs: %{
                      url: Conn.request_url(conn),
                      user_agent: user_agent_string(conn),
                      end_user: end_user(conn),
                      status_code: conn.status,
                      response_time: response_time
                    }
        conn
      end
    )
  end

  defp response_time(start_time) do
    System.monotonic_time()
    |> Kernel.-(start_time)
    |> System.convert_time_unit(:native, :microsecond)
  end

  defp user_agent_string(conn) do
    conn
    |> Conn.get_req_header("user-agent")
    |> List.first()
  end

  defp end_user(%Conn{assigns: %{user: %{email: email}}}), do: email
  defp end_user(%Conn{remote_ip: {b1, b2, b3, b4}}),       do: Enum.join([b1, b2, b3, b4], ".")

end