
defmodule HealthWebWeb.PostComponent do
  use HealthWebWeb, :live_component
  alias HealthWebWeb.FetchDataSource

  def mount(socket) do
    category =
      FetchDataSource.fetch_json("/category.json")
      |> Enum.map(fn item ->
        id = CommonComponents.batch_string(item["title"])
        Map.put(item, "id", id)
      end)
    {:ok, socket |> assign(category: category)}
  end

  def get_category(id, category) do
    case Enum.find(category, fn item -> item["id"] == id end) do
      %{"title" => title} -> title
      _ -> nil
    end
  end
end
