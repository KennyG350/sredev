defmodule Sre.EmailDelveryTest do
  use ExUnit.Case

  import Bamboo.Email
  use Bamboo.Test, shared: true

  alias Sre.Service.Email.Composer

  setup do
    params = %{
      "email" => "test@gmail.com",
      "first_name" => "orion",
      "last_name" => "engleton",
      "message" => "I want this house",
      "state" => "CA",
      "property_address" => "172 BLISS CANYON Road Bradbury, California 91008"
    }
    {:ok, params: params}
  end

  test ".send_property_details_email", %{params: params} do
    Composer.send_property_details_email(params)
    assert_received {:delivered_email, _}
  end

  test ".send_seller_email", %{params: params} do
    Composer.send_seller_email(params)
    assert_received {:delivered_email, _}
  end

  test ".send_contact_email", %{params: params} do
    Composer.send_contact_email(params)
    assert_received {:delivered_email, _}
  end

  test "email gets dispatched" do

    envelope = compose(
      to_email: "orion.engleton@gmail.com",
      from_email: "salad@salad.com",
      subject: "Lets talk Real Estate"
    )

    bamboo_email = envelope |> html_body("<h1>I am html</h1>")

    Composer.deliver bamboo_email

    assert_delivered_email(bamboo_email)
  end

  defp compose(opts) do
    new_email
    |> to(opts[:to_email])
    |> from(opts[:from_email])
    |> subject(opts[:subject])
  end

end
