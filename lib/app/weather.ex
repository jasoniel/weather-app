defmodule App.Weather do

  def get_appid() do
    "0bcf652efd8dea74b57b7cbed241d355"
  end

  def get_endpoint(location) do
    location = URI.encode(location)
    "http://api.weatherstack.com/current?access_key=#{get_appid()}&query=#{location}"
  end

  def kelvin_to_celsius(kelvin) do
    (kelvin - 273.15)
    |> Float.round(1)
  end

  def temperature_of(location) do
    result = get_endpoint(location)
             |> HTTPoison.get
             |> parser_response

    case result do
      {:ok, temp} -> "#{location}: #{temp} ºC"
      :error -> "#{location} not found"
    end
  end

  defp parser_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do

    body
    |> JSON.decode!
    |> compute_temperature


  end


  defp parser_response(_), do: :error

  defp compute_temperature(json) do
    try do
      temp = json["current"]["temperature"]
      {:ok, temp}
    rescue
      _ -> :error
    end
  end


  def start(cities) do
    manager_pid =  spawn(__MODULE__, :manager, [[], Enum.count(cities)])

    cities |> Enum.map(fn city ->
      pid = spawn(__MODULE__, :get_temperature, [])
      send pid, {manager_pid, city}
    end)
  end

  def get_temperature() do
    receive do
      {manager_pid, location} ->
        send(manager_pid, {:ok, temperature_of(location)})
        _ ->
          IO.puts "Error"
        # code
    end
    get_temperature()
  end

  def manager(cities \\ [], total) do
    receive do
      {:ok, temp} ->
        results = [ temp | cities]
        if(Enum.count(results) == total) do
          send self(), :exit
        end
        manager(results, total)
      :exit ->
        IO.puts(cities |> Enum.sort |> Enum.join(", "))
      _ ->
        manager(cities, total)
        # code
    end

  end
end
