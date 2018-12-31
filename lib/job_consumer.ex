defmodule TikTak.JobConsumer do
  use GenStage
  alias TikTak.{Job, JobProducer}

  @user_agent  "TikTak/#{Mix.Project.config[:version]}"

  def start_link(args) do
    GenStage.start_link(__MODULE__, args)
  end

  def init(_) do
    {:consumer, [], subscribe_to: [{JobProducer, max_demand: 1}]}
  end

  def handle_events([job], _from, state) do
    %Job{
      callback_url: callback_url
    } = job
    HTTPoison.post(callback_url, "", [{"User-Agent", @user_agent}])
    {:noreply, [], state}
  end
end