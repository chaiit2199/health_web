defmodule HealthWebWeb.SearchComponent do
  use HealthWebWeb, :live_component
  alias CommonComponents

  @suggest_list ["Đau đầu", "Mất ngủ", "Viêm họng", "Tiểu đường", "Huyết áp cao", "Stress", "Đau lưng", "Dị ứng"]

  def mount(socket) do
    {:ok, socket
      |> assign(quick_search: nil)
     |> assign(suggest_list: @suggest_list)
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
    filtered_data = fetch_data(socket.assigns.diseases, params["search_key"])
    {:noreply, socket
      |> assign(filtered_data: filtered_data)
    }
  end

  def handle_event("quick_search", %{"value" => value}, socket) do
    filtered_data = fetch_data(socket.assigns.diseases, value)
    {:noreply, socket
      |> assign(quick_search: value)
      |> assign(filtered_data: filtered_data)
    }
  end

  def fetch_data(data ,params) do
    data
    |> Enum.filter(fn disease ->
        String.contains?(CommonComponents.batch_string(disease), CommonComponents.batch_string(params))
      end)
  end
end
