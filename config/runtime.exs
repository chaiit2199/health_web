import Config

if config_env() == :prod do

  host = System.get_env("HOST") || "localhost"
  http_port = String.to_integer(System.get_env("PORT") || "80")
  secret_key_base = System.get_env("SECRET_KEY_BASE") || raise ("No SECRET_KEY_BASE config.")
  base_url = System.get_env("BASE_URL")

  config :health_web, HealthWebWeb.Endpoint,
    server: true,
    host: host,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: http_port
    ],
    secret_key_base: secret_key_base

  config :health_web,
    env: config_env(),
    base_url: base_url
end
