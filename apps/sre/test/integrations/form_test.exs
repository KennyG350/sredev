defmodule Sre.FormTest do
  use ExUnit.Case
  use Hound.Helpers

  @base_qa_url "http://sreqa.com"

  alias Hound.Helpers.Session

  setup do
    Hound.start_session [driver: %{os: "OS X", os_version: "El Capitan", javascriptEnabled: true}]
    :ok
  end

  setup_all do
    base_elements = [
      %{text: "Browser", name: "first_name"},
      %{text: "Stack", name: "last_name"},
      %{text: "browserstacktest@gmail.com", name: "email"},
    ]

    {:ok, base_elements: base_elements}
  end

  test "The buyer form can be submitted", %{base_elements: elements} do
    navigate_to(@base_qa_url <> "/buy")

    buy_elements = [
      %{text: "1231231231", name: "phone"},
      %{text: "automation testing on browser stack", name: "message"}
    ]

    elements
    |> Enum.concat(buy_elements)
    |> Enum.each(fn e ->
                  :name |> find_element(e.name) |> fill_field(e.text)
                end)

    :class |> find_element("button--cta") |> click

    :timer.sleep 3000

    submit_message = :tag
    |> find_all_elements("p")
    |> Enum.at(2)
    |> inner_html

    assert(submit_message == "Your request has been successfully sent, thank you!")

    Session.end_session
  end

  test "The seller form can be submitted", %{base_elements: elements} do
    navigate_to(@base_qa_url <> "/sell")

    sell_elements = [
      %{text: "1231231231", name: "phone"},
      %{text: "an address I want to sell", name: "address"}
    ]

    elements
    |> Enum.concat(sell_elements)
    |> Enum.each(fn e ->
                  :name
                  |> find_element(e.name)
                  |> fill_field(e.text)
                end)

    :class
    |> find_element("button--cta")
    |> click

    :timer.sleep 3000

    submit_message = :tag
    |> find_all_elements("p")
    |> Enum.at(2)
    |> inner_html

    assert(submit_message == "Your request has been successfully sent, thank you!")

    Session.end_session
  end

  test "The buyer form for a property can be submitted", %{base_elements: elements} do
    navigate_to(@base_qa_url <> "/properties/883-denise-el-cajon-ca-92020-1dcbd34d")

    buy_elements = [
      %{text: "automation testing on browser stack", name: "message"}
    ]

    elements
    |> Enum.concat(buy_elements)
    |> Enum.each(fn e ->
                :name |> find_element(e.name) |> fill_field(e.text)
              end)

    :class |> find_element("button--cta") |> click

    :timer.sleep 3000

    submit_message = :tag
    |> find_all_elements("p")
    |> Enum.at(4)
    |> inner_html

    assert(submit_message == "Your request has been successfully sent, thank you!")

    Session.end_session
  end
end
