defmodule TikTak.Schedule do
  use Ecto.Schema
  require Ecto.Query
  alias Ecto.{Query, Changeset}
  alias TikTak.{Schedule, Job}

  @primary_key {:id, :string, []}

  schema "schedules" do
    field :cron, :string
    field :date, :string
    field :delay, :integer
    field :callback_url, :string
    field :status, :string, default: "pending"
    field :priority, :integer, default: 5
    field :execution_count, :integer, default: 0
    has_many :jobs, Job
  end

  def get(id) do
    Query.from(s in Schedule, where: s.id == ^id)
  end

  def get_pending(limit) do
    Query.from(s in Schedule, where: s.status == "pending", order_by: [s.priority], limit: ^limit)
  end

  def create(schedule) do
    %Schedule{}
    |> Changeset.cast(schedule, [:id, :cron, :date, :delay, :callback_url, :priority])
    |> Changeset.validate_required([:id, :callback_url])
    |> validate_one_is_required([:cron, :date, :delay])
    |> validate_cron(:cron)
    |> validate_date(:date)
    |> Changeset.validate_number(:delay, greater_than: 0)
  end

  def set_scheduled(schedule) do
    schedule
    |> Changeset.change(%{status: "scheduled"})
  end

  def set_for_reschedule(schedule_ids) do
    Query.from(
      s in Schedule,
      where: s.id in ^schedule_ids,
      update: [
        set: [
          status: "pending"
        ],
        inc: [
          execution_count: 1
        ]
      ]
    )
  end

  defp validate_one_is_required(changeset, [field | _] = fields) do
    count = Enum.count(fields, fn field -> Changeset.get_field(changeset, field) != nil end)
    case count do
      1 -> changeset
      _ -> changeset
           |> Changeset.add_error(field, "Exactly one of #{inspect fields} is required")
    end
  end

  defp validate_cron(changeset, field) do
    Changeset.validate_change(
      changeset,
      field,
      fn _, cron ->
        case Crontab.CronExpression.Parser.parse(cron, true) do
          {:ok, _} -> []
          {:error, error} -> [{field, error}]
        end
      end
    )
  end

  defp validate_date(changeset, field) do
    Changeset.validate_change(
      changeset,
      field,
      fn _, date ->
        case NaiveDateTime.from_iso8601(date) do
          {:ok, _} -> []
          {:error, _} -> [{field, "Date must be in ISO 8601 format"}]
        end
      end
    )
  end
end