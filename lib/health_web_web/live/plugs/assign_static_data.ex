defmodule HealthWebWeb.AssignStaticData do
  use HealthWebWeb, :live_view
  alias FetchAPI


  def on_mount(:fetch_static_data, _params, _session, socket) do
    {:cont, assign(socket, static_data: fetch_diseases())}
  end

  defp fetch_diseases() do
    base_api = Application.get_env(:health_web, :base_url, [])
    FetchAPI.get("/diseases")
  end
end
