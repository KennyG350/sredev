defmodule Sre.Listing.ViewHelperTest do
  use ExUnit.Case

  doctest Sre.Listing.ViewHelper

  alias Sre.Listing.ViewHelper

  test "format address" do
    assert ViewHelper.address(%{
      :street_number => "123",
      :street_dir_prefix => "S",
      :street_name => "Main",
      :street_suffix => "St",
      :street_dir_suffix => "SE",
      :unit_number => "",
      :city => "Phoenix",
      :state => "AZ",
      :zip_code => "85021"
    }) === "123 S Main St SE Phoenix, AZ 85021"
  end

  test "format address with unit number" do
    assert ViewHelper.address(%{
      :street_number => "123",
      :street_dir_prefix => "W",
      :street_name => "Main",
      :street_suffix => "St",
      :street_dir_suffix => "",
      :unit_number => "42",
      :city => "Phoenix",
      :state => "AZ",
      :zip_code => "85021"
    }) === "123 W Main St #42 Phoenix, AZ 85021"
  end

  test "format street address" do
    assert ViewHelper.street_address(%{
      :street_number => "123",
      :street_dir_prefix => "W",
      :street_name => "Main",
      :street_suffix => "St",
      :street_dir_suffix => "",
      :unit_number => "42",
      :city => "Phoenix",
      :state => "AZ",
      :zip_code => "85021"
    }) === "123 W Main St #42"
  end

  test "format city state zip" do
    assert ViewHelper.city_state_zip(%{
      :street_number => "123",
      :street_dir_prefix => "W",
      :street_name => "Main",
      :street_suffix => "St",
      :street_dir_suffix => "",
      :unit_number => "42",
      :city => "Phoenix",
      :state => "AZ",
      :zip_code => "85021"
    }) === "Phoenix, AZ 85021"
  end

  test "format date_listed" do
    {_, listed_date} = Timex.parse("2016-07-19T14:35:13.590000Z Etc/UTC", "{ISO:Extended}")

    assert ViewHelper.date_listed(%{
      :original_entry_timestamp => listed_date
    }) === "7/19/2016"
  end

  test "calc days on market" do
    {_, listed_date} = Timex.parse("2016-07-19T14:35:13.590000Z Etc/UTC", "{ISO:Extended}")

    assert ViewHelper.days_on_market(%{
      :original_entry_timestamp => listed_date
    }) === Timex.diff(Timex.now, listed_date, :days)
  end

  test "calc days on market when nil" do
    assert ViewHelper.days_on_market(%{
      :original_entry_timestamp => nil
    }) === "-"
  end

  test "format number" do
    assert ViewHelper.format_number("10000") === "10,000"
  end

  test "format number no commas" do
    assert ViewHelper.format_number("100") === "100"
  end

  test "format number when nil" do
    assert ViewHelper.format_number(nil) === "-"
  end

  test "format number when int" do
    assert ViewHelper.format_number(100_000) === "100,000"
  end

  test "format number when decimal" do
    assert ViewHelper.format_number(Decimal.new("100000.22")) === "100,000"
  end

  test "format currency when decimal" do
    assert ViewHelper.format_currency(Decimal.new("100000.22")) === "$100,000"
  end

  test "format currency when int" do
    assert ViewHelper.format_currency(100_000) === "$100,000"
  end

  test "format currency when string" do
    assert ViewHelper.format_currency("100000") === "$100,000"
  end

  test "format currency when nil" do
    assert ViewHelper.format_currency(nil) === "-"
  end

  test "price_per_sqft/1 should take a listing and be able to handle 0 for living area" do
    assert ViewHelper.price_per_sqft(%{price: 100, living_area: 0}) === "-"
  end

  test "price_per_sqft/1 should return `-` if either the price or living area is `nil`" do
    assert ViewHelper.price_per_sqft(%{price: 100, living_area: nil}) === "-"
    assert ViewHelper.price_per_sqft(%{price: nil, living_area: nil}) === "-"
    assert ViewHelper.price_per_sqft(%{price: nil, living_area: 12}) === "-"
  end

  test "price_per_sqft/2 should take a price and living_area and returns the cost when the living area is greater than 0" do
    assert ViewHelper.price_per_sqft(100, 10) === "$10"
  end

  test "price_per_sqft/2 should take a price and living_area and returns `-` when the living area is 0" do
    assert ViewHelper.price_per_sqft(100, 0) === "-"
  end

  test "to_acres/1 if argument is `nil` returns `-`" do
    assert ViewHelper.to_acres(nil) === "-"
  end

  test "to_acres/1 returns `-` if sqft is not able to convert to float" do
    assert ViewHelper.to_acres("!") === "-"
  end

  test "to_acres/1 converts `sqft` and returns acres" do
    assert ViewHelper.to_acres(43_560) === 1.00
    assert ViewHelper.to_acres("43560") === 1.00
  end

  test "render_ACR/1 will return `-` if `-` is passed" do
    assert ViewHelper.render_ACR("-") === "-"
  end

  test "render_ACR/1 will return ACR appened into string" do
    assert ViewHelper.render_ACR("123.12") === "123.12 ACR"
    assert ViewHelper.render_ACR(123.12) === "123.12 ACR"
  end

end
