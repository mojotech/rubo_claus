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
end

class MyClassTest < Minitest::Test
  def test_define_function
    k = MyClass.new

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
  end
end
