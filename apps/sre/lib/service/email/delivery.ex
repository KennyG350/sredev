defmodule Sre.Service.Email.Delivery do
  @moduledoc """
  This module houses functions that send out emails.
  """
  import Sre.Router.Helpers, only: [
    user_management_email_url: 4
  ]

  alias Sre.{
    Tokenizer,
    Service.Email.Composer
  }

  @doc """
  Takes in %User{} or #Ecto.Changeset< data: #User<> >
  returns {:ok, %User{}}
  """
  def send_verify_email(user, email, conn \\ Sre.Endpoint) do
    user =
      user
      |> Tokenizer.verify_email_token(true)
    user
    |> Composer.send_verify_email(generate_url(conn, user, email), email)
    {:ok, Map.put(user, :requested_email, true)}
  end

  defp generate_url(conn, user, email) do
    user_management_email_url conn, :verify, user, token: user.verify_email_token, email: email
  end

end
