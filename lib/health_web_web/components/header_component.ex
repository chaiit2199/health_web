
defmodule HealthWebWeb.HeaderComponent do
  use HealthWebWeb, :live_component

  def mount(socket) do
    {:ok,
     socket
     |> assign(modal: nil)}
  end

  def handle_event("open_modal", %{"modal" => modal}, socket) do
    {:noreply,
     socket
     |> assign(modal: "show_menu")}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply,
     socket
     |> assign(modal: nil)}
  end
end
