defmodule AppTest do
  use ExUnit.Case

  @api "http://api.weatherstack.com/current?"


  test "should return a encoded endpoint wen take a location" do
    appid = App.Weather.get_appid()
    endpoint = App.Weather.get_endpoint("Rio de Janeiro")

    assert "#{@api}access_key=#{appid}&query=Rio%20de%20Janeiro" == endpoint
  end

  test "should return Celsius when take Kelvin" do
    kelvin_example =  296.48
    celsius_example = 23.3
    temperature = App.Weather.kelvin_to_celsius(kelvin_example)

    assert temperature == celsius_example
  end

  test "should return temperature when take a valid location" do
    temperature = App.Weather.temperature_of("Rio de Janeiro")

    assert String.contains?(temperature, "Rio de Janeiro") == true
  end

  test "should return not found when take an invalid location" do
    result = App.Weather.temperature_of("00000")

    assert result ==="00000 not found"
  end
end
