defimpl Poison.Encoder, for: ListingSearch.Listing do
  def encode(model, opts) do
    model
    |> Map.drop([:__meta__, :__struct__])
    |> Poison.Encoder.encode(opts)
  end
end

defimpl Poison.Encoder, for: DateTime do
  def encode(dt, opts) do
    {:ok , {{year, month, day}, {hour, min, sec, _}}} = Timex.Ecto.DateTime.dump dt

    %Ecto.DateTime{year: year, month: month, day: day, hour: hour, min: min, sec: sec}
    |> Poison.Encoder.encode(opts)
  end
end
