defmodule HealthWebWeb.FooterComponent do
  use HealthWebWeb, :live_component
  alias HealthWebWeb.FetchDataSource

  def update(assigns, socket) do
    new_recents = assigns.recents |> Enum.take(2)
      socket =
        socket
        |> assign(assigns)
        |> assign(:new_recents, new_recents)
      {:ok, socket}
  end
end
