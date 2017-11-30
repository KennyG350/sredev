defmodule Sre.UserLocation do

  # @default_ip_address "23.229.204.137"
  @default_ip_address "206.195.188.239"

  defstruct city: nil, state: nil, zip: nil, latitude: nil, longitude: nil, ip: nil

  @doc """
   Look up the `UserLocation` based off an ip such as "8.8.8.8"
  """
  def from_ip(nil), do: {:error, "No IP address provided"}
  def from_ip({127, 0, 0, 1}), do: from_ip(@default_ip_address)
  def from_ip(ip) do
    case Geolix.lookup ip do
      %{city: location} ->
        {:ok, %Sre.UserLocation{
          city: get_city_name(location),
          state: get_state_name(location),
          longitude: get_long(location),
          latitude: get_lat(location),
          zip: get_zip(location),
          ip: ip
        }}
      _ ->
        {:error, "Error looking up location"}
    end
  end

  defp get_city_name(%{city: %{name: name}}), do: name
  defp get_city_name(_), do: nil

  defp get_state_name(%{subdivisions: [%{iso_code: name}|_]}), do: name
  defp get_state_name(_), do: nil

  defp get_long(%{location: %{longitude: long}}), do: long
  defp get_long(_), do: nil

  defp get_lat(%{location: %{latitude: lat}}), do: lat
  defp get_lat(_), do: nil

  defp get_zip(%{postal: %{code: code}}), do: code
  defp get_zip(_), do: nil

end
