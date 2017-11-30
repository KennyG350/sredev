defmodule Sre.UserManagement.PasswordView do
  use Sre.Web, :view

  def update_password_url(user) do
    "/mysre/edit-profile/#{user.id}/change_password?token=" <>
      "#{user.forgot_password_token}&email=#{user.email}"
  end
end
