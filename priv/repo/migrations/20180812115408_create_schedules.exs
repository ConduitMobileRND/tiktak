defmodule TikTak.Repo.Migrations.CreateSchedules do
  use Ecto.Migration

  def change do
    create table(:schedules, primary_key: false) do
      add :id, :string, primary_key: true
      add :cron, :string
      add :date, :string
      add :delay, :integer
      add :callback_url, :string
      add :status, :string
      add :priority, :integer
      add :execution_count, :integer
    end
    create index(:schedules, [:status, :priority])
  end
end
