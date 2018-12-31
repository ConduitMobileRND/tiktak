defmodule TikTak.Router do
  use Plug.Router
  require Logger
  alias Ecto.Multi
  alias TikTak.{Schedule, Job, Repo, JobProducer}

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:json], json_decoder: Poison
  plug :match
  plug :dispatch

  get "/", do: send_resp(conn, 200, "All set!")

  put "/schedule/:id" do
    schedule = conn.body_params
               |> Map.put("id", id)
               |> Schedule.create()

    Multi.new()
    |> Multi.delete_all("delete_#{id}_jobs", Job.get_by_schedule(id))
    |> Multi.delete_all("delete_#{id}", Schedule.get(id))
    |> Multi.insert("create_#{id}", schedule)
    |> Repo.transaction()
    |> case do
         {:ok, _} -> send_resp(conn, 200, "Scheduled!")
         {:error, _, %{errors: errors}, _} ->
           send_resp(conn, 400, inspect errors)
         error ->
           Logger.warn inspect error
           send_resp(conn, 500, "")
       end
  end

  delete "/schedule/:id" do
    Multi.new()
    |> Multi.delete_all("delete_#{id}_jobs", Job.get_by_schedule(id))
    |> Multi.delete_all("delete_#{id}", Schedule.get(id))
    |> Repo.transaction()

    send_resp(conn, 200, "Deleted!")
  end

  match "_shutdown" do
    JobProducer.stop()
    send_resp(conn, 200, "It's now safe to turn off your computer")
  end

  match _, do: send_resp(conn, 404, "?")
end