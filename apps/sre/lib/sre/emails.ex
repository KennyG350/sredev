defmodule Sre.Emails do
  import Bamboo.Email

  def rewards_email(contact) do
    email_contents = "<strong>First Name:</strong> #{contact["first_name"]}<br>" <>
    "<strong>Last Name:</strong> #{contact["last_name"]}<br>" <>
    "<strong>Phone Number:</strong> #{contact["phone"]}<br>" <>
    "<strong>Email:</strong> #{contact["email"]}<br>" <>
    "<strong>Message:</strong><br> #{contact["message"]}"

    new_email()
    |> to(System.get_env("REWARDS_EMAIL"))
    |> from("no-reply@sre.com")
    |> subject("New SRE Rewards Submission")
    |> html_body(email_contents)
  end
end
