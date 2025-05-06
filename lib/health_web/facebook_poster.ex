defmodule FacebookPoster do
  use GenServer
  alias FetchAPI
  alias CommonComponents

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def stop() do
    GenServer.stop(__MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_info(:post, state) do
    share_post()
    {:noreply, state}
  end

  def post do
    share_post()
  end

  def share_post do
    access_token = Application.get_env(:health_web, :access_token)
    page_id = Application.get_env(:health_web, :page_id)
    graph_url = "https://graph.facebook.com/#{page_id}/feed"

    IO.inspect(label: "share_postxxx")
    diseases = fetch_recent_diseases()

    if diseases != [] do
      Enum.each(diseases, fn disease ->
        IO.inspect(disease, label: "share_postxxx")
        message = "📢 Bài viết #{disease["updated_at"]}: #{disease["name"]}"
        body = URI.encode_query(%{
          message: message,
          link: "https://99tek.com/health-consultation/#{disease["title"]}",
          access_token: access_token
        })

        headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

        case HTTPoison.post(graph_url, body, headers, timeout: 60_000) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            IO.puts("✅ Đã share bài: #{disease["name"]} thành công!")
            IO.inspect(body)

          {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
            IO.puts("❌ Lỗi Facebook khi share bài #{disease["name"]}: #{code}")
            IO.inspect(body)

          {:error, err} ->
            IO.puts("❌ HTTP Error khi share bài #{disease["name"]}:")
            IO.inspect(err)
        end
      end)
    else
      IO.puts("❌ Không có bài viết nào mới để chia sẻ.")
    end
  end

  def fetch_recent_diseases() do
    base_api = Application.get_env(:health_web, :base_url, [])
    FetchAPI.get("/get_posts_today")
  end
end
