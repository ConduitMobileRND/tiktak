defmodule TikTak.Scheduler do
  require Ecto.Query
  alias Ecto.Multi
  alias TikTak.{Schedule, Job, Repo}

  def child_spec(opts), do: %{id: __MODULE__, start: {__MODULE__, :start_link, [opts]}}

  def start_link(_) do
    pid = spawn_link(__MODULE__, :schedule, [])
    {:ok, pid}
  end

  def schedule do
    query_until_available()
    |> schedule()

    schedule()
  end

  defp query_until_available(schedules \\ [], sleep \\ 0)

  defp query_until_available([], sleep) do
    Process.sleep(sleep)
    schedules = Schedule.get_pending(100)
                |> Repo.all
    query_until_available(schedules, 1_000)
  end

  defp query_until_available(schedules, _), do: schedules

  defp schedule(schedules) do
    schedules
    |> schedule(Multi.new())
    |> Repo.transaction()
  end

  defp schedule([schedule | rest], multi) do
    multi = schedule(schedule, multi)
    schedule(rest, multi)
  end

  defp schedule([], multi), do: multi

  defp schedule(%{delay: delay, execution_count: 0} = schedule, multi) when delay != nil do
    date = NaiveDateTime.utc_now()
           |> NaiveDateTime.add(delay)
    schedule(schedule, date, multi)
  end

  defp schedule(%{date: date, execution_count: 0} = schedule, multi) when date != nil do
    date = NaiveDateTime.from_iso8601!(date)
    schedule(schedule, date, multi)
  end

  defp schedule(%{cron: cron, execution_count: 0} = schedule, multi) when cron != nil do
    date = Crontab.CronExpression.Parser.parse!(cron, true)
           |> Crontab.Scheduler.get_next_run_date()
           |> case do
                {:ok, date} -> date
                {:error, _} -> NaiveDateTime.utc_now()
              end
    schedule(schedule, date, multi)
  end

  defp schedule(%{cron: cron} = schedule, multi) when cron != nil do
    date_or_nil = Crontab.CronExpression.Parser.parse!(cron, true)
                  |> Crontab.Scheduler.get_next_run_date()
                  |> case do
                       {:ok, date} -> date
                       {:error, _} -> nil
                     end
    schedule(schedule, date_or_nil, multi)
  end

  defp schedule(schedule, multi) do
    schedule(schedule, nil, multi)
  end

  defp schedule(schedule, _date = nil, multi) do
    Multi.delete(multi, "delete_#{schedule.id}", schedule)
  end

  defp schedule(schedule, date, multi) do
    %{id: schedule_id, callback_url: callback_url, priority: priority} = schedule
    schedule = Schedule.set_scheduled(schedule)
    job = %{
            schedule_id: schedule_id,
            next_run: date
                      |> DateTime.from_naive!("Etc/UTC")
                      |> DateTime.to_unix,
            callback_url: callback_url,
            priority: priority
          }
          |> Job.create
    multi
    |> Multi.update("update_#{schedule_id}}", schedule)
    |> Multi.insert("create_#{schedule_id}_job", job)
  end
end