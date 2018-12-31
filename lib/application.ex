defmodule TikTak.Application do
  use Application
  alias TikTak.{Repo, Scheduler, JobProducer, JobConsumer, Router}

  def start(_type, _args) do
    concurrency_limit = Application.get_env(:tiktak, :concurrency_limit)
                        |> to_string()
                        |> Integer.parse()
                        |> elem(0)
    children = [
                 Repo,
                 Scheduler,
                 JobProducer,
                 Enum.map(
                   1..concurrency_limit,
                   fn i ->
                     Supervisor.child_spec({JobConsumer, []}, id: String.to_atom("job_consumer_#{i}"))
                   end
                 ),
                 {Plug.Adapters.Cowboy, scheme: :http, plug: Router, options: [{:port, 8080}]}
               ]
               |> List.flatten
    opts = [strategy: :rest_for_one, name: Scheduler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end