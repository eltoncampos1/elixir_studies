defmodule SumListTest do
  use ExUnit.Case

  describe "call/1" do
    test "should returns the list sum" do
      list = [1, 2, 3]

      response = SumList.call(list)

      expected_response = 6

      assert response == expect_response
    end
  end
end
