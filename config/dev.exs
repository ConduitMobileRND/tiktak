use Mix.Config

config :tiktak,
       TikTak.Repo,
       adapter: Ecto.Adapters.Postgres,
       database: "postgres",
       username: "postgres",
       password: "postgres",
       hostname: "172.17.0.3"