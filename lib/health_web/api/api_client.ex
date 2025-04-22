defmodule FetchAPI do

  def get(path) do
    base_url_api = Application.get_env(:health_web, :base_url)
    origin = (Application.get_env(:health_web, HealthWebWeb.Endpoint)[:host] || "")
    url = "#{base_url_api}/#{path}"
    headers = [{"origin", origin}]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode!(body)

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.puts("Status code: #{status_code}")
        {:error, status_code}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("HTTP Error: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
