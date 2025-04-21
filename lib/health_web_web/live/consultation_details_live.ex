defmodule HealthWebWeb.ConsultationDetailsLive do
  use HealthWebWeb, :live_view
  alias HealthWebWeb.CommonComponents



  def mount(_params, _session, socket) do
    Task.start(__MODULE__, :task_get_recent_post, [self()])
    {:ok, socket |> assign(recent_post: [])}
  end

  def handle_params(params, _uri, socket) do
    response = fetch_diseases_details(params["params_id"])
    case get_in(response, ["response", "data"]) do
      nil ->
        {:noreply, socket}

      data when is_binary(data) ->
        json_response = %{
          "data" => data,
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
          |> assign(updated_at: json_response["updated_at"])
          |> assign(parsed_data: parsed_data)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_info({:result_get_recent_post, data}, socket) do
    {:noreply,
     socket
     |> assign(recent_post: data || %{})}
  end

  defp fetch_diseases_details(params) do
    base_api = Application.get_env(:health_web, :base_url, [])
    case HTTPoison.get("#{base_api}/ai/?params=#{URI.encode(params)}") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode!(body)

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        %{"response" => %{"params_id" => nil, "data" => nil}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        %{"response" => %{"params_id" => nil, "data" => nil}}
    end
  end

  defp fetch_recent_post() do
    base_api = Application.get_env(:health_web, :base_url, [])
    case HTTPoison.get("#{base_api}/recent_diseases") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode!(body)
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.puts(status_code)

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts(reason)
    end
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
