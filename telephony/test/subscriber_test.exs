defmodule SubscriberTest do
  use ExUnit.Case
  doctest Subscriber

  setup do
    File.write("plans/pre.txt", :erlang.term_to_binary([]))
    File.write("plans/post.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("plans/pre.txt")
      File.rm("plans/post.txt")
    end)
  end

  describe "Create Subscriber Test" do

    test "Should be able to create an prepaid account" do
      assert Subscriber.register("user123", "123", "123", :prepaid) == {:ok, "Subscriber user123 has been successfully registered"}
    end

    test "Should be return error if user already registered" do
      Subscriber.register("user123", "123", "123", :prepaid)
      assert Subscriber.register("user123", "123", "123", :prepaid) ==  {:error, "Subscriber with this number already registered"}
    end

    test "Should be return an Subscriber struct" do
      assert %Subscriber{name: "user123", number: "123", cpf: "123", plan: :postpaid}.name == "user123"
    end

  end

  describe "Find Subscribers Test" do

    test "find postpaid" do
      Subscriber.register("user123", "123", "123", :postpaid)

      assert Subscriber.find_subscriber("123", :postpaid).name == "user123"
    end

    test "if subscriber postpaid number is found return nil" do
      Subscriber.register("user123", "123", "123", :postpaid)

      assert Subscriber.find_subscriber("0", :postpaid) == nil
    end

    test "find prepaid" do
      Subscriber.register("user123", "123", "123", :prepaid)

      assert Subscriber.find_subscriber("123", :prepaid).name == "user123"
    end

    test "if subscriber prepaid number is found return nil" do
      Subscriber.register("user123", "123", "123", :prepaid)

      assert Subscriber.find_subscriber("0", :postpaid) == nil
    end

    test "find all" do
      Subscriber.register("user123", "123", "123", :prepaid)
      Subscriber.register("user456", "456", "456", :postpaid)

      assert Subscriber.find_subscriber("123").name == "user123"
    end

    test "if subscriber number is found return nil" do
      Subscriber.register("user123", "123", "123", :prepaid)

      assert Subscriber.find_subscriber("0") == nil
    end
  end

  describe "Delete Subscriber" do

    test "Should delete an subscriber" do
      Subscriber.register("user123", "123", "123", :prepaid)

      assert Subscriber.delete("123") == {:ok, "Subscriber user123 successfully deleted."}
    end
  end

end
