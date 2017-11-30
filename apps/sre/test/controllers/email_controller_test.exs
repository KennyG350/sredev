defmodule Sre.EmailControllerTest do
  use Sre.ConnCase

  describe "Base Email functionality" do

    test ".create", %{conn: conn} do

      email = %{"email" => "test@gmail.com",
                "first_name" => "orion",
                "last_name" => "engleton",
                "message" => "I want this house",
                "state" => "CA",
                "property_address" => "172 BLISS CANYON Road Bradbury, California 91008"
              }

      response = post(conn, email_path(conn, :property_details, email))
      assert json_response(response, 200)["status"] == "OK"
    end

  end
end
