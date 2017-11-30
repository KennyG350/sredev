defmodule Sre.UI.Svg.IconTest do
  use ExUnit.Case, aysnc: true

  alias Sre.UI.Svg.Icon

  test ".class_name/2 handles nil has frist argument" do
    classes = Icon.class_name nil, "classname"
    assert classes == "classname"
  end

  test ".class_name/2 handles empty list as first argument" do
    classes = Icon.class_name [], "classname"
    assert classes == "classname"
  end

  test ".class_name/2 concats classnames together corrert"  do
    classes = Icon.class_name ["blue", "green"], "icon"
    assert classes == "icon blue green"
  end

end
