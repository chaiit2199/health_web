defmodule HealthWebWeb.HomeLive do
  use HealthWebWeb, :live_view

  def mount(_params, _session, socket) do
    diseases = socket.assigns.static_data
    recents = socket.assigns.recents_post

    {:ok,
     socket
     |> assign(diseases: diseases)
     |> assign(recents: recents)
     |> assign(modal: nil)}
  end

  def handle_event("show_modal", %{"modal" => modal}, socket) do
    {:noreply,
     socket
     |> assign(modal: modal)}
  end


  def handle_event("close_modal", _, socket) do
    {:noreply,
     socket
     |> assign(modal: nil)}
  end
end
