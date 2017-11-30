defmodule Sre.EmailComposerTest do
  use ExUnit.Case

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

  describe "Routing" do
    test "change email to california email", %{params: params} do
      bamboo = Composer.process(:property_details, params)
      assert bamboo.to == "sandiego@sre.com"
    end

    test "DOES NOT change email to california email", %{params: params} do
      bamboo = Composer.process(:seller, params)
      refute bamboo.to == "sandiego@sre.com"
      assert bamboo.to == "qa@knledg.com"
    end

    test "DOES NOT change email to arizona email", %{params: params} do
      bamboo = Composer.process(:seller, params)
      refute bamboo.to == "arizona@sre.com"
      assert bamboo.to == "qa@knledg.com"
    end

    test "change email to AZ email", %{params: params} do
      params = Map.merge(params, %{"state" => "AZ"})
      bamboo = Composer.process(:property_details, params)
      assert bamboo.to == "arizona@sre.com"
    end

    test "change email to HI email", %{params: params} do
      params = Map.merge(params, %{"state" => "HI"})
      bamboo = Composer.process(:property_details, params)
      assert bamboo.to == "info@sre.com"
    end

  end

  test ".html/2 should add html to a `Bamboo.Email`" do
    email = Composer.compose(html: "<h1>I am html</h1>")
    html_data = email.html_body
    assert html_data =~ "<h1>I am html</h1>"
  end

  test "process(:contact)", %{params: params} do
    email_struct = Composer.process(:contact, params)
    assert %Bamboo.Email{} = email_struct
    assert email_struct.subject == "New Contact from SRE.com"
    assert email_struct.html_body =~ "I want this house"
  end

  test "process(:property_details)", %{params: params} do
    email_struct = Composer.process(:property_details, params)
    assert %Bamboo.Email{} = email_struct
    assert email_struct.subject == "New Interested Buyer from SRE.com"
    assert email_struct.html_body =~ "I want this house"
  end

  test "process(:seller)", %{params: params} do
    email_struct = Composer.process(:seller, params)
    assert %Bamboo.Email{} = email_struct
    assert email_struct.subject == "New Interested Seller from SRE.com"
    assert email_struct.html_body =~ "is interested in selling their property"
  end

end
