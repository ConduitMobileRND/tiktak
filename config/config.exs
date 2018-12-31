use Mix.Config

config :tiktak,
       ecto_repos: [TikTak.Repo],
       concurrency_limit: 10

config :logger,
       backends: [:console],
       level: :info

config :logger,
       :console,
       format: "$time [$level] $metadata $message\n",
       metadata: [:module, :pid]

import_config "#{Mix.env}.exs"