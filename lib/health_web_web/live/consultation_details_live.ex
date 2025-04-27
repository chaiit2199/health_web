defmodule HealthWebWeb.ConsultationDetailsLive do
  use HealthWebWeb, :live_view
  alias HealthWebWeb.CommonComponents
  alias FetchAPI


  def mount(_params, _session, socket) do
    Task.start(__MODULE__, :task_get_recent_post, [self()])
    recents = socket.assigns.recents_post
    diseases = socket.assigns.static_data

    {:ok, socket
      |> assign(diseases: diseases)
      |> assign(recent_post: [])
      |> assign(modal: nil)
      |> assign(recents: recents)
    }
  end

  def handle_params(params, uri, socket) do
    dafault = socket.assigns.recents
    |> List.first()
    |> Map.get("title")

    response = fetch_diseases_details(params["params_id"] || dafault)

    case get_in(response, ["response", "data"]) do
      nil ->
        {:noreply, socket}

      data when is_binary(data) ->
        json_response = %{
          "data" => data,
          "category" => get_in(response, ["response", "category"]),
          "name" => get_in(response, ["response", "name"]),
          "updated_at" => get_in(response, ["response", "updated_at"])
        }

      parsed_data =
        json_response["data"]
        |> Jason.decode!()
        |> Enum.map(fn map ->
          [{key, value}] = Map.to_list(map)
          %{title: key, content: value}
        end)

        |> Enum.map(fn %{title: title, content: content} ->
          updated =
            content
            |> then(fn text ->
              if Regex.match?(~r/(\d+\.\s*)\*\*(.+?)\*\*/, text) do
                Regex.replace(~r/(\d+\.\s*)\*\*(.+?)\*\*/, text, fn _, num, text ->
                  ~s(<p class="item">#{num}#{text}</p>)
                end)
              else
                text
              end
            end)
            |> then(fn text ->
              if Regex.match?(~r/\*\*(.+?)\*\*/, text) do
                Regex.replace(~r/\*\*(.+?)\*\*/, text, fn _, text ->
                  ~s(<p class="item">#{text}</p>)
                end)
              else
                text
              end
            end)
            |> String.replace(" \n", "\n")
            |> String.replace(~r/\s+/, " ")
            |> String.replace(~r/ \./, ".")
            |> String.replace(~r/ ,/, ",")
            |> String.trim()
            |> String.split("\n")

          %{title: title, content: updated}
        end)

        {:noreply,
          socket
          |> assign(modal: nil)
          |> assign(show: false)
          |> assign(title: json_response["name"])
          |> assign(banner: "/assets/images/posts/#{json_response["category"]}.jpg")
          |> assign(updated_at: json_response["updated_at"])
          |> assign(parsed_data: parsed_data)
          |> assign(desc_post: List.first(parsed_data)[:content] |> List.first())
          |> assign(post_url: uri)
        }

      _ ->
        {:noreply, socket}
    end
  end

  def handle_info({:result_get_recent_post, data}, socket) do
    {:noreply,
     socket
     |> assign(recent_post: data || %{})}
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

  defp fetch_diseases_details(params) do
    FetchAPI.get("/ai/?params=#{URI.encode(params)}")
  end

  defp fetch_recent_post() do
    FetchAPI.get("/recent_diseases")
  end

  def format_date(string) do
    {:ok, datetime} = NaiveDateTime.from_iso8601(string)
    formatted = Calendar.strftime(datetime, "%d/%m/%Y")
  end

  def handle_async(:recent, {:ok, items}, socket) do
    async = socket.assigns.recents
    {:noreply, assign(socket, recents_post: AsyncResult.ok(async, items))}
  end

  def handle_async(:recent, {:exit, reason}, socket) do
    async = socket.assigns.recents
    {:noreply, assign(socket, recents: AsyncResult.failed(async, {:error, reason}))}
  end

  def task_get_recent_post(pid \\ []) do
    Process.send(
      pid,
      {:result_get_recent_post, fetch_recent_post()},
      []
    )
  end
end
