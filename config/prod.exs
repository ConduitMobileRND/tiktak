use Mix.Config

config :tiktak,
       concurrency_limit: "${TIKTAK_CONCURRENCY_LIMIT}"

config :logger,
       level: :warn

config :tiktak,
       TikTak.Repo,
       adapter: Ecto.Adapters.Postgres,
       database: "${TIKTAK_REPO_DATABASE}",
       username: "${TIKTAK_REPO_USERNAME}",
       password: "${TIKTAK_REPO_PASSWORD}",
       hostname: "${TIKTAK_REPO_HOSTNAME}"