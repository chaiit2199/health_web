# HealthWeb

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


// API generate access_token expires_in 60 days (note tele)

vào đây để lấy  access_token: https://developers.facebook.com/tools/explorer?method=GET&path=855872054769528&version=v22.0
https://graph.facebook.com/v18.0/me/accounts?access_token= để lấy access_token2

call truyền access_token2
https://graph.facebook.com/v18.0/oauth/access_token?
    grant_type=fb_exchange_token&
    client_id={app-id}&
    client_secret={app-secret}&
    fb_exchange_token={access_token2} để gia hạn


