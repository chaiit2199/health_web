defmodule HealthWebWeb.AssignStaticData do
  use HealthWebWeb, :live_view


  def on_mount(:fetch_static_data, _params, _session, socket) do
    {:cont, assign(socket, static_data: fetch_diseases())}
  end

  defp fetch_diseases() do
    base_url Application.get_env(:health_web, :base_url, [])

    case HTTPoison.get("#{base_url}/diseases") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        diseases = Jason.decode!(body)

      {:error, reason} ->
        IO.puts(reason)
    end
  end
end
