defmodule Remedy.Api.Ratelimiter do
  @moduledoc """
  Ratelimit implimentation specific to Discord's API.
  Only to be used when starting in a rest-only manner.
  """

  use GenServer

  alias Remedy.Api.{Base, Bucket}
  alias Remedy.Error.ApiError
  alias Remedy.Util

  require Logger

  @typedoc """
  Return values of start functions.
  """
  @type on_start ::
          {:ok, pid}
          | :ignore
          | {:error, {:already_started, pid} | term}

  @major_parameters ["channels", "guilds", "webhooks"]
  @gregorian_epoch 62_167_219_200

  @doc """
  Starts the ratelimiter.
  """
  @spec start_link([]) :: on_start
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: Ratelimiter)
  end

  def init([]) do
    :ets.new(:ratelimit_buckets, [:set, :public, :named_table])
    {:ok, []}
  end

  @doc """
  Empties all buckets, voiding any saved ratelimit values.
  """
  @spec empty_buckets() :: true
  def empty_buckets do
    :ets.delete_all_objects(:ratelimit_buckets)
  end

  def handle_call({:queue, request, original_from}, from, state) do
    retry_time =
      request.route
      |> get_endpoint(request.method)
      |> Bucket.get_ratelimit_timeout()

    case retry_time do
      :now ->
        GenServer.reply(original_from || from, do_request(request))

      time when time < 0 ->
        GenServer.reply(original_from || from, do_request(request))

      time ->
        Task.start(fn ->
          wait_for_timeout(request, time, original_from || from)
        end)
    end

    {:noreply, state}
  end

  defp do_request(request) do
    request.method
    |> Base.request(request.route, request.body, request.headers, request.options)
    |> handle_headers(get_endpoint(request.route, request.method))
    |> format_response
  end

  defp handle_headers({:error, reason}, _route), do: {:error, reason}

  defp handle_headers({:ok, %HTTPoison.Response{headers: headers}} = response, route) do
    headers_to_keep =
      MapSet.new([
        "x-ratelimit-global",
        "x-ratelimit-remaining",
        "x-ratelimit-reset",
        "retry-after",
        "date"
      ])

    kept_headers = filter_headers(headers, headers_to_keep)

    global_limit = Map.get(kept_headers, "x-ratelimit-global")
    remaining = to_integer(Map.get(kept_headers, "x-ratelimit-remaining"))
    reset = to_integer(Map.get(kept_headers, "x-ratelimit-reset"))
    retry_after = to_integer(Map.get(kept_headers, "retry-after"))
    origin_timestamp = date_string_to_unix(Map.get(kept_headers, "date"))

    latency = abs(origin_timestamp - Util.now())

    if global_limit, do: update_global_bucket(route, 0, retry_after, latency)
    if reset, do: update_bucket(route, remaining, reset, latency)

    response
  end

  defp update_bucket(route, remaining, reset_time, latency) do
    Bucket.update_bucket(route, remaining, reset_time * 1000, latency)
  end

  defp update_global_bucket(_route, _remaining, retry_after, latency) do
    Bucket.update_bucket("GLOBAL", 0, retry_after + Util.now(), latency)
  end

  defp wait_for_timeout(request, timeout, from) do
    Logger.info(
      "RATELIMITER: Waiting #{timeout}ms to process request with route #{request.route}"
    )

    Process.sleep(timeout)
    GenServer.call(Ratelimiter, {:queue, request, from}, :infinity)
  end

  defp date_string_to_unix(header) do
    header
    |> String.to_charlist()
    |> :httpd_util.convert_request_date()
    |> erl_datetime_to_timestamp
  end

  defp erl_datetime_to_timestamp(datetime) do
    (:calendar.datetime_to_gregorian_seconds(datetime) - @gregorian_epoch) * 1000
  end

  defp to_integer(v) when is_binary(v), do: String.to_integer(v)
  defp to_integer(_v), do: nil

  @doc """
  Retrieves a proper ratelimit endpoint from a given route and url.
  """
  @spec get_endpoint(String.t(), atom) :: String.t()
  def get_endpoint(route, method) do
    endpoint =
      Regex.replace(~r/\/([a-z-]+)\/(?:[0-9]{17,19})/i, route, fn capture, param ->
        case param do
          param when param in @major_parameters ->
            capture

          param ->
            "/#{param}/_id"
        end
      end)

    if String.ends_with?(endpoint, "/messages/_id") and method == :delete do
      "delete:" <> endpoint
    else
      endpoint
    end
  end

  defp format_response(response) do
    case response do
      {:error, error} ->
        {:error, error}

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 204}} ->
        {:ok}

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, %ApiError{status_code: code, response: Poison.decode!(body, keys: :atoms)}}
    end
  end

  # Will go through headers and keep the ones that are members of the headers_to_keep MapSet (case insensitive!)
  defp filter_headers(headers, headers_to_keep) do
    headers
    |> Stream.map(fn {key, value} ->
      {String.downcase(key), value}
    end)
    |> Stream.filter(fn {key, _v} -> MapSet.member?(headers_to_keep, key) end)
    |> Enum.into(%{})
  end
end
