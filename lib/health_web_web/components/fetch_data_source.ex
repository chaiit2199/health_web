defmodule HealthWebWeb.FetchDataSource do
  use HealthWebWeb, :live_component
  alias Jason

  def fetch_data(path) do
    file_path =
      File.read(to_string(:code.priv_dir(:health_web)) <> path) || []

    case file_path do
      {:ok, res} ->
        case Jason.decode(res) do
          {:ok, data} -> data
          {:error, _reason} -> %{}
        end

      {:error, _} ->
        %{}
    end
  end

  def fetch_json(path) do
    fetch_data("/json/" <> path)
    # fetch_data("/static/assets/files/" <> path) // firebase inactive
  end
end
