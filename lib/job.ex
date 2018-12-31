defmodule TikTak.Job do
  use Ecto.Schema
  require Ecto.Query
  alias Ecto.{Query, Changeset}
  alias TikTak.{Schedule, Job}

  schema "jobs" do
    belongs_to :schedule, Schedule, type: :string
    field :next_run, :integer
    field :callback_url, :string
    field :priority, :integer, default: 5
  end

  def get(job_ids) do
    Query.from(j in Job, where: j.id in ^job_ids)
  end

  def get_by_schedule(schedule_id) do
    Query.from(j in Job, where: j.schedule_id == ^schedule_id)
  end

  def get_mature(limit) do
    current_time = DateTime.utc_now
                   |> DateTime.to_unix
    Query.from(j in Job, where: j.next_run < ^current_time, order_by: [j.priority, j.next_run], limit: ^limit)
  end

  def create(job) do
    %Job{}
    |> Changeset.cast(job, [:schedule_id, :next_run, :callback_url, :priority])
    |> Changeset.validate_required([:schedule_id, :next_run, :callback_url])
  end
end