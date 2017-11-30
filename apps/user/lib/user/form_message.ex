defmodule User.FormMessage do
  @moduledoc """
    Module for working with users and their form messages
  """

  import Ecto, only: [build_assoc: 2]

  alias Schema.{
    Repo,
    Resource.User,
    Resource.UserFormMessage
  }

  def message_for_user(%User{} = user) do
    user
    |> build_assoc(:form_messages)
  end

  def add_message(%UserFormMessage{} = form_message, message) do
    form_message
    |> UserFormMessage.changeset(%{message: message})
  end

  def insert_message!(form_message_changeset),
    do: Repo.insert! form_message_changeset

end
