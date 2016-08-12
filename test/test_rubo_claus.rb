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
end
