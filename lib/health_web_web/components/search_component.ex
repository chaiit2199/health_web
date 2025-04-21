defmodule HealthWebWeb.SearchComponent do
  use HealthWebWeb, :live_component
  alias CommonComponents


  def mount(socket) do
    {:ok, socket
     |> assign(response: nil)
     |> assign(filtered_data: [])
    }
  end

  def update_many(assigns_sockets) do
    Enum.map(assigns_sockets, fn {assigns, socket} ->
      socket
      |> assign(assigns)
      |> assign(filtered_data: [])
    end)
  end

  def handle_event("change", params, socket) do
    filtered_data =
      socket.assigns.diseases
      |> Enum.filter(fn disease ->
        String.contains?(CommonComponents.batch_string(disease), CommonComponents.batch_string(params["search_key"]))
      end)

    {:noreply, socket
      |> assign(filtered_data: filtered_data)
    }
  end
end
