import Config

if config_env() == :prod do

  host = System.get_env("HOST") || "localhost"
  host_request = System.get_env("HOST_REQUEST") || "localhost"
  http_port = String.to_integer(System.get_env("HTTP_PORT") || "81")
  https_port = String.to_integer(System.get_env("HTTPS_PORT") || "80")
  secret_key_base = System.get_env("SECRET_KEY_BASE") || raise ("No SECRET_KEY_BASE config.")
  base_url = System.get_env("BASE_URL")

  protocol_options = [
    secure_renegotiations: true,
    ciphers:
      :"ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305",
    versions: [:"tlsv1.2", :"tlsv1.3"],
    options: [:secure_renegotiations, :no_sslv2, :no_sslv3, :no_tlsv1, :no_tlsv1_1]
  ]

  host_cert_file = System.get_env("HOST_CERT_FILE") || raise "No host cert file config."
  host_key_file = System.get_env("HOST_KEY_FILE") || raise "No host key file config."

  config :health_web, HealthWebWeb.Endpoint,
    server: true,
    host: host_request,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: http_port
    ],
    https: [
      protocol_options: protocol_options,
      port: https_port,
      cipher_suite: :strong,
      keyfile: host_key_file,
      certfile: host_cert_file
    ],
    secret_key_base: secret_key_base

  config :health_web,
    env: config_env(),
    base_url: base_url
end
