defmodule HealthWebWeb.AssignStaticData do
  use HealthWebWeb, :live_view

  @api_url Application.get_env(:health_web, :base_url, [])

  def on_mount(:fetch_static_data, _params, _session, socket) do
    {:cont, assign(socket, static_data: fetch_diseases())}
  end

  defp fetch_diseases() do
    case HTTPoison.get("#{@api_url}/diseases") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        diseases = Jason.decode!(body)

      {:error, reason} ->
        IO.puts(reason)
    end
  end
end
