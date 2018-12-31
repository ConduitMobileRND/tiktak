defmodule TikTak.JobProducer do
  use GenStage
  require Logger
  alias Ecto.Multi
  alias TikTak.{Schedule, Job, Repo}

  ## Client API

  def stop() do
    Logger.warn "Stopping producer"
    Process.whereis(__MODULE__)
    |> send(:stop)
    Process.sleep(5_000)
  end

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  ## Server API

  def init(_), do: {:producer, []}

  def handle_demand(1, []) do
    jobs = query_until_available()
           |> mark_as_done()
    handle_demand(1, jobs)
  end

  def handle_demand(1, [:stop] = state) do
    Logger.warn "Producer stopped, buffering demand"
    {:noreply, [], state}
  end

  def handle_demand(1, [job | rest]) do
    {:noreply, [job], rest}
  end

  def handle_info(:stop, state) do
    {:noreply, [], state ++ [:stop]}
  end

  defp query_until_available(jobs \\ [], sleep \\ 0)

  defp query_until_available([], sleep) do
    Process.sleep(sleep)
    jobs = Job.get_mature(100)
           |> Repo.all()
    query_until_available(jobs, 1_000)
  end

  defp query_until_available(jobs, _), do: jobs

  defp mark_as_done(jobs) do
    schedules = jobs
                |> Enum.map(&(&1.schedule_id))
                |> Schedule.set_for_reschedule()
    Multi.new()
    |> Multi.update_all("update_schedules", schedules, [])
    |> Multi.delete_all("delete_jobs", Job.get(Enum.map(jobs, &(&1.id))))
    |> Repo.transaction()

    jobs
  end
end