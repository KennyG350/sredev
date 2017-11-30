defmodule Sre.Support.Helpers do

  alias Ecto.UUID

  def user_details do
    %{
      :first_name => "Jane",
      :last_name => "Doe",
      :picture => "http://string/to/photo",
      :email => "#{UUID.generate}@sre.com",
      :email_verified => true,
      :auth_0_id => UUID.generate
     }
  end

end
