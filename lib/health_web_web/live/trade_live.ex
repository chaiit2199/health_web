defmodule HealthWebWeb.TradeLive do
  use HealthWebWeb, :live_view
  alias Phoenix.PubSub

  @pubsub_name BackendPubsub.PubSub
  @pubsub_topic_stock_prefix "stock:dynamic"

  @datalist [
      %{name: "CTP", value: 20.0},
      %{name: "DHT", value: 16.0},
      %{name: "VGI", value: 10.0},
      %{name: "TTN", value: 25.0},
      %{name: "CSV", value: 10.0},
      %{name: "VTP", value: 11.0},
      %{name: "PIV", value: 13.0},
      %{name: "VTZ", value: 12.0},
      %{name: "LPB", value: 28.0},
      %{name: "VIB", value: 20.0}
    ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(datalist: @datalist)

    # Subscribe vào PubSub topic @pubsub_topic_stock_prefix
    PubSub.subscribe(@pubsub_name, @pubsub_topic_stock_prefix)

    {:ok, socket}
  end

  @impl true
  def handle_info({:update_price, {stock_name, stock_value}}, socket) do
    # Cập nhật giá trị mới trong danh sách
    updated_datalist =
      Enum.map(socket.assigns.datalist, fn stock ->
        if stock[:name] == stock_name do
          %{stock | value: stock_value}
        else
          stock
        end
      end)

    {:noreply, assign(socket, datalist: updated_datalist)}
  end


end
