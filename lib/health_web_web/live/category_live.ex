defmodule HealthWebWeb.CategoryLive do
  use HealthWebWeb, :live_view
  alias HealthWebWeb.FetchDataSource
  alias FetchAPI


  def mount(_params, _session, socket) do
    category =
      FetchDataSource.fetch_json("/category.json")
      |> Enum.map(fn item ->
        id = CommonComponents.batch_string(item["title"])
        Map.put(item, "id", id)
      end)
      {:ok, socket
      |> assign(page_end: false)
      |> assign(category_post: [])
      |> assign(category: category)}
  end

  def handle_params(params, _uri, socket) do
    Task.start(__MODULE__, :task_get_category_post, [self(), params])
    current_category =  params["params"] || "dinh-duong"
    current_page =  params["page"] || "1"
    category_details =
      socket.assigns.category
      |> Enum.find(&(&1["id"] == current_category))
      {:noreply, socket

      |> assign(current_category: current_category)
      |> assign(current_page: String.to_integer(current_page))
      |> assign(category_details: category_details)}
  end

  def handle_info({:result_get_category_post, data}, socket) do
    {:noreply,
     socket
     |> assign(page_end: length(data) < 10)
     |> assign(category_post: data || %{})}
  end

  def task_get_category_post(pid \\ [], params) do
    Process.send(
      pid,
      {:result_get_category_post, fetch_category_post(params)},
      []
    )
  end

  def handle_event("change_page", %{"page" => page}, socket) do
    IO.inspect(page, label: "yeiduqwyeqiweuyqw")
    {:noreply, socket |> push_patch(to: "/category/#{socket.assigns.current_category}?page=#{page}")}
  end

  defp fetch_category_post(params) do
    FetchAPI.get("category?category=#{params["params"]}&page=#{params["page"] || 1}")
  end
end
