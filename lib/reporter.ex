defmodule Locux.Reporter do
  alias HttpUtil.StatusCode

  def render(result, num_of_workers) do
    num_of_total_results = length(result)

    successful_results = Enum.filter(result, fn(x) -> elem(x, 0) == 200 end)
    total_error_results =
      result
      |> Enum.filter(fn(x) -> elem(x, 0) != 200 end)
      |> Enum.group_by(&(elem(&1, 0)))

    print_success_rate(successful_results, num_of_total_results)
    print_errors(total_error_results, num_of_total_results)

    if length(successful_results) > 0 do
      print_times(successful_results)
      if num_of_workers > 1 do
        print_concurrency(successful_results)
      end
    end
  end

  defp print_success_rate(successful_results, num_of_total_results) do
    success = length(successful_results)

    IO.puts "Success: #{success}/#{num_of_total_results} (#{success/num_of_total_results * 100}%)"
  end

  defp print_errors(total_error_results, num_of_total_results) do
    total_error_results
    |> Enum.each(fn {error_code, error_results} ->
      errors = length(error_results)
      status_code = StatusCode.status_code(error_code, :description)
      IO.puts "Error #{error_code} (#{status_code}): #{errors}/#{num_of_total_results} (#{errors/num_of_total_results * 100}%)"
    end)
  end

  defp print_times(result) do
    times = result |> Enum.map(&elem(&1, 1)) |> Enum.map(&(&1 / 1000))

    max_val = Enum.max(times)
    min_val = Enum.min(times)
    avg_val = Enum.sum(times) / length(times)
    iqrm_val = Statistics.trimmed_mean(times, :iqr)

    IO.puts "Times:"
    IO.puts "   Max:      #{format_number(max_val)} ms"
    IO.puts "   Min:      #{format_number(min_val)} ms"
    IO.puts "   Avg:      #{format_number(avg_val)} ms"
    IO.puts "   IQR mean: #{format_number(iqrm_val)} ms"
  end

  defp print_concurrency(result) do
    times = result |> Enum.map(&elem(&1, 1)) |> Enum.map(&(&1 / 1000))
    start = result |> Enum.map(&elem(&1, 2)) |> Enum.map(&(&1 / 1000)) |> Enum.min
    finish = result |> Enum.map(&elem(&1, 3)) |> Enum.map(&(&1 / 1000)) |> Enum.max

    total_duration = finish - start
    sum_of_times = Enum.sum(times)
    requests = length(result)
    IO.puts "Concurrency:"
    IO.puts "   Time of all requests:  #{format_number(sum_of_times)} ms"
    IO.puts "   Total duration:        #{format_number(total_duration)} ms"
    IO.puts "   Concurrency level:     #{format_number(sum_of_times/total_duration)}"
    IO.puts "   Requests per second:   #{format_number(requests/(total_duration/1000))} req/s"
  end

  defp format_number(num) do
    Float.round(num, 2)
  end
end
