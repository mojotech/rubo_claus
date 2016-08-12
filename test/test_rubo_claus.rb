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

  define_function :add_one do
    clauses(
      clause([0], proc { |n| "Dont add one to zero please!" }),
      clause([NilClass], proc { |n| 42 }),
      clause([:any], proc { |n| n + 1 }),
      catch_all(proc { raise NoMethodError, "no clause defined} "})
    )
  end

  define_function :greeting do
    clauses(
      clause([String], proc { |str| "Hello, #{str}!" }),
      clause([String, String], proc { |greet, str| "#{greet}, #{str}!"})
    )
  end

  define_function :any_test do
    clauses(
      clause([1, :any, 3], proc { |n1, any, n3| "#{n1} ANY 2" }),
      clause([:any, 2, 3], proc { |any, n2, n3| "ANY 2 3" }),
      clause([:any, 2, :any], proc { |ne1, n2, ne2| "ANY 2 ANY" })
    )
  end
end

class MyClassTest < Minitest::Test
  def test_simple_clauses
    k = MyClass.new
    assert_equal "Dont add one to zero please!", k.add_one(0)
    assert_equal 3, k.add_one(2)
    assert_equal 42, k.add_one(nil)
    assert_raises NoMethodError do
      k.add_one(1,2,3, [:b])
    end
  end

  def test_variadic_arity
    k = MyClass.new
    assert_equal "Hello, Newman!", k.greeting("Newman")
    assert_equal "Bye Bye, Dolly!", k.greeting("Bye Bye", "Dolly")
  end

  def test_mixed_location_any_terms
    k = MyClass.new
    assert_equal "1 ANY 2", k.any_test(1,999,3)
    assert_equal "ANY 2 3", k.any_test(999,2,3)
    assert_equal "ANY 2 ANY", k.any_test(999,2,987)
  end

  def test_no_catch_all_clause_defined
    k = MyClass.new

    assert_raises RuboClaus::NoPatternMatchError do
      k.greeting(1,2,3,)
    end

    assert_raises RuboClaus::NoPatternMatchError do
      k.greeting(["Goat"])
    end
  end
end
