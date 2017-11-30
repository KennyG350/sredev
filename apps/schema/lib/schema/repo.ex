defmodule Schema.Repo do
  use Ecto.Repo, otp_app: :schema

  alias Ecto.{
    Adapters.SQL,
    DateTime,
    Schema,
    Type
  }

  def expire_date(count) do
    erl_time = :calendar.universal_time
    erl_time
    |> Timex.shift(days: count)
    |> DateTime.cast!
  end

  def execute_and_load(sql, params, model) do
    __MODULE__
    |> SQL.query!(sql, params)
    |> load_into(model)
  end

  defp load_into(response, model) do
    Enum.map(response.rows, fn row ->
      fields = Enum.reduce(Enum.zip(response.columns, row), %{}, fn({key, value}, map) ->
        Map.put(map, key, value)
      end)
    Schema.__load__(model, nil, nil, nil, fields, &Type.adapter_load(__adapter__, &1, &2))
    end)
  end

end
