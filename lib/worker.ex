defmodule Locux.Worker do
  require Logger

  def call(agent, url, num_of_requests, opts) do
    for _ <- 1..num_of_requests, do: work(agent, url, num_of_requests, opts)
    work(agent, url, num_of_requests, opts)
  end

  defp work(_, _, 0, _) do
  end

  defp work(agent, url, requests_to_do, opts) do
    connection_header = if opts[:keep_alive], do: "keep-alive", else: "close"

    start = :erlang.system_time() / 1000
    headers = opts[:headers] ++ [{"Connection", connection_header}]

    Logger.debug fn -> "#{__MODULE__} #{inspect url} #{inspect headers}" end

    response = HTTPoison.get(url, headers, hackney: [pool: :workers_pool])
    finish = :erlang.system_time() / 1000
    time = finish - start

    case response do
      {:ok, response} ->
        Agent.update(agent, fn list -> [{response.status_code, time, start, finish}|list] end)
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.debug fn -> "#{__MODULE__} Failed request: #{inspect reason}" end
        Agent.update(agent, fn(list) -> [{0, 0, 0, 0}|list] end)
    end

    work(url, agent, requests_to_do - 1, opts)
  end
end
