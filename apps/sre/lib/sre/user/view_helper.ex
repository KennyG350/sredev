defmodule Sre.User.ViewHelper do
  def get_current_user_first_name(nil), do: ""
  def get_current_user_first_name(user) do
    user.first_name || ""
  end

  def get_current_user_last_name(nil), do: ""
  def get_current_user_last_name(user) do
    user.last_name || ""
  end

  def get_current_user_email(nil), do: ""
  def get_current_user_email(user) do
    user.email || ""
  end

  def get_current_user_phone(nil), do: ""
  def get_current_user_phone(%{user_phones: []}), do: ""
  def get_current_user_phone(%{user_phones: [phone | _tail] = phones}) when is_list(phones) do
    phone.phone_number
  end
  def get_current_user_phone(_user), do: ""
end
