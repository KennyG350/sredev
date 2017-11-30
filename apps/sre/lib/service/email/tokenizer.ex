defmodule Sre.Tokenizer do
  @moduledoc """
   Purpose of this module is to house logic that creates and sets tokens
   that have to do with changing emails, passwords, etc.
  """
  alias Schema.{Repo, Resource.User}
  alias Ecto.{Changeset, DateTime}

  @doc """
  Takes in Tokenizer.verify_email_token(%User{}, boolean)
  pattern matching instead of if statement on result.
  """
  def verify_email_token(user, true) do
      user
      |> verify_email_token(false)
      |> Changeset.put_change(:email_verified, false)
      |> Repo.update!
  end

  def verify_email_token(user, false) do
    user |> User.changeset(:change_email)
  end

  def fetch_and_validate(token) do
    user = Repo.get_by(User, verify_email_token: token)
    if expired?(user) do
      {:valid, user}
    else
      {:expired, user}
    end
  end

  defp expired?(%{verify_email_expiration: expire_date}) do
    now = :calendar.universal_time |> DateTime.from_erl
    now < expire_date
  end

end
