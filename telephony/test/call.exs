defmodule CallTest do
  use ExUnit.Case

  test "Should test struct" do
    assert %Call{date: DateTime.utc_now(), duration: 30}.duration == 30
  end
end
