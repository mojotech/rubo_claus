require 'minitest/autorun'
require 'rubo_claus'
require 'rubo_claus/version'

class RuboClausTest < Minitest::Test
  def test_has_version_number
    refute_nil RuboClaus::VERSION
  end
end

class MyClass
  include RuboClaus

  define_function :return_thing do
    clauses(
      clause([Array], proc { |n| n.inspect }),
      clause([:any], proc { |n| n })
    )
  end

  define_function :return_two_things do
    clauses(
      clause([:any, :any], proc { |n, n1| [n, n1] }),
      clause([:any], proc { "Please use two things, not one." })
    )
  end

  define_function :welcome_persons_named_tim do
    clauses(
      clause(["Tim"], proc { "Please welcome Tim."}),
      catch_all(proc { "You are not Tim." })
    )
  end

  define_function :fib do
    clauses(
      clause([0], proc { 0 }),
      clause([1], proc { 1 }),
      clause([Fixnum], proc { |num| fib(num-1) + fib(num-2) })
    )
  end

  define_function :get_head_and_tail_shallow do
    clauses(
      clause([[String, :any, :tail], :any], proc { |n, n1, n2_tail, n3| {first: n, second: n1, third: n2_tail, fourth: n3} }),
      clause([[:any, :tail], :any], proc { |n, n1_tail, n2| {first: n, second: n1_tail, third: n2} })
    )
  end

  define_function :friend_hash_des do
    clauses(
      clause([{friend: String}], proc { |n| "I know everything about #{n[:friend]}" })
    )
  end

  define_function :night_emergency_phone do
    param_shape = {username: String, friends: Array, phone: {fax: :any, mobile: String, emergency: {day: String, night: String}}}

    clauses(
      clause([param_shape], proc do |data|
               data[:phone][:emergency][:night]
             end)
    )
  end

  define_function :count do
    clauses(
      clause([Array], proc { |array| count(array, 0) }),
      clause([[], Fixnum], proc { |_array, sum| sum }),
      clause([[:any, :tail], Fixnum], proc { |_head, tail, sum| count(tail, sum + 1) })
    )
  end

  define_function :count_with_private do
    clauses(
      clause([Array], proc { |array| count_with_private(array, 0) }),
      p_clause([[], Fixnum], proc { |_array, sum| sum }),
      p_clause([[:any, :tail], Fixnum], proc { |_head, tail, sum| count_with_private(tail, sum + 1) })
    )
  end
end

class MyClassTest < Minitest::Test
  def test_define_function
    k = MyClass.new

    assert_equal '[1]', k.return_thing([1])
    assert_equal 1, k.return_thing(1)
  end

  def test_using_clauses_and_variadic_arity
    k = MyClass.new

    assert_equal [1, 2], k.return_two_things(1, 2)
    assert_equal "Please use two things, not one.", k.return_two_things(1)

    assert_raises RuboClaus::NoPatternMatchError do
      k.return_two_things(1, 2, 3)
    end
  end

  def test_using_catchall
    k = MyClass.new

    assert_equal "Please welcome Tim.", k.welcome_persons_named_tim("Tim")
    assert_equal "You are not Tim.", k.welcome_persons_named_tim("Don")
  end

  def test_using_recursion
    k = MyClass.new

    assert_equal 0, k.fib(0)
    assert_equal 1, k.fib(1)
    assert_equal 1, k.fib(2)
    assert_equal 2, k.fib(3)
    assert_equal 3, k.fib(4)

    assert_equal 3, k.count([1, 2, 3])
    assert_equal 1, k.count([1])

    assert_equal 3, k.count_with_private([1, 2, 3])

    assert_raises RuboClaus::NoPatternMatchError do
      k.count_with_private([1, 2, 3], 3)
    end
  end

  def test_shallow_hash_destructuring
    k = MyClass.new

    assert_equal "I know everything about John", k.friend_hash_des({friend: "John", foe: 3})

    assert_raises RuboClaus::NoPatternMatchError do
      k.friend_hash_des({})
    end
  end

  def test_shallow_head_tail_destructuring
    k = MyClass.new
    output = {first: 1, second: [2, 3, 4], third: 5}
    second_output = {first: "1", second: 2, third: [3, 4], fourth: 5}

    assert_equal output, k.get_head_and_tail_shallow([1, 2, 3, 4], 5)
    assert_equal second_output, k.get_head_and_tail_shallow(["1", 2, 3, 4], 5)
  end

  def test_compound_data_destructuring
    k = MyClass.new

    param = {username: "Sally Moe", friends: [], phone: {fax: "NA", mobile: "123-345-1232", emergency: {day: "123-123-1234", night: "999-999-9999", weekend: '123-123-1233'}}}
    assert_equal "999-999-9999", k.night_emergency_phone(param)

    assert_raises RuboClaus::NoPatternMatchError do
      param = {username: "Sally Moe", friends: "", phone: {fax: "NA", mobile: "123-345-1232", emergency: [{day: "123-123-1234", night: "999-999-9999"}]}}
      k.night_emergency_phone(param)
    end
  end
end
