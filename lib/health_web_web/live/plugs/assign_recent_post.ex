defmodule HealthWebWeb.AssignRecentPost do
  use HealthWebWeb, :live_view
  alias FetchAPI


  def on_mount(:fetch_recent_diseases, _params, _session, socket) do
    {:cont, assign(socket, recents_post: fetch_recent_diseases())}
  end

  defp fetch_recent_diseases() do
    base_api = Application.get_env(:health_web, :base_url, [])
    FetchAPI.get("/recent_diseases")
  end
end
