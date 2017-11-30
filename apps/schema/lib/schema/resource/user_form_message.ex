defmodule Schema.Resource.UserFormMessage do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schema.Resource.{
    User
  }

  schema "user_form_messages" do
    belongs_to :user, User
    field :message, :string
  end

  @allowed [:message]

  def changeset(form_message, params \\ %{}) do
    form_message
    |> cast(params, @allowed)
    |> cast_assoc(:user)
  end
end
