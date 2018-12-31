defmodule TikTak.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :schedule_id, references("schedules", type: :string)
      add :next_run, :integer
      add :callback_url, :string
      add :priority, :integer
    end
    create index(:jobs, [:schedule_id])
    create index(:jobs, [:priority, :next_run])
  end
end
