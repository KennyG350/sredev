defmodule Sre.Service.Email.Composer do
  @moduledoc """
    * functions that compose, transform and deliver emails.
  """

  import Bamboo.Email

  use Bamboo.Phoenix, view: Sre.EmailView

  alias Sre.Mailer

  @default_to Application.get_env(:sre, :to_email)
  @default_from Application.get_env(:sre, :from_email)

  def send_property_details_email(params) do
    :property_details |> process(params) |> deliver
  end

  def send_seller_email(params) do
    :seller |> process(params) |> deliver
  end

  def send_contact_email(params) do
    :contact |> process(params) |> deliver
  end

  def send_reset_password_email(nil, _), do: {:failure, :not_on_file}

  def send_reset_password_email(user, url) do
    subj = "Your SRE.com Password reset link."
    bamboo_email = do_base_email(user, url, subj, "email_reset.html")
    bamboo_email |> deliver
  end

  def send_registration_email(user, url) do
    subj = "You recently registered SRE.com Verify new account"
    bamboo = do_base_email(user, url, subj, "new_registration.html")
    bamboo |> deliver
  end

  defp do_base_email(%{first_name: fname, last_name: lname,  email: email}, url, subject, template) do
    subject
    |> build_email(email)
    |> assign(:name, "#{fname} #{lname}")
    |> assign(:email, email)
    |> assign(:reset_link, url)
    |> assign(:verify_link, url)
    |> render(template)
  end

  def send_verify_email(%{first_name: fname, last_name: lname, verify_email_token: _token}, url, email) do
    name = "#{fname} #{lname}"
    email_struct = build_email("Your SRE.com email change request", email)
    bamboo =
      email_struct
      |> assign(:name, name)
      |> assign(:email, email)
      |> assign(:verify_link, url)
      |> render("verify_email.html")
    bamboo |> deliver
  end

  def process(:seller, params) do
    email_struct = build_email("New Interested Seller from SRE.com")
    do_process(email_struct, params, "seller_form.html")
  end

  def process(:property_details, params) do
    email_struct = build_email("New Interested Buyer from SRE.com", params)
    do_process(email_struct, params, "property_details_form.html")
  end

  def process(:contact, params) do
    email_struct = build_email("New Contact from SRE.com")
    do_process(email_struct, params, "contact_form.html")
  end

  def compose(opts \\ []) do
    new_email()
    |> to(opts[:to_email])
    |> from(opts[:from_email])
    |> subject(opts[:subject])
    |> html_body(opts[:html])
  end

  defp do_process(bamboo, params, template) do
    bamboo
    |> assign(:first_name, params["first_name"])
    |> assign(:last_name, params["last_name"])
    |> assign(:message, params["message"])
    |> assign(:phone, params["phone"])
    |> assign(:email, bamboo.from)
    |> assign(:property_address, params["property_address"])
    |> render(template)
  end

  defp build_email(subject) do
    compose to_email: @default_to, from_email: @default_from, subject: subject
  end

  defp build_email(subject, %{"state" => state}) do
    compose to_email: (state_email(state) || @default_to),
      from_email: @default_from, subject: subject
  end

  defp build_email(subject, to_email)
  when is_binary(to_email) do
    compose to_email: to_email, from_email: @default_from, subject: subject
  end

  defp state_email(state) do
    state_atom = state
    |> String.downcase
    |> String.to_atom
    Application.get_env(:sre, :state_emails)[state_atom]
  end

  def deliver(%Bamboo.Email{} = email) do
    case Mailer.deliver_now email do
      %Bamboo.Email{} = new_email ->
        {:success, new_email}
      error ->
        {:failure, email, error}
    end
  end

end
