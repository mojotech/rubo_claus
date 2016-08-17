require 'minitest/autorun'
require 'match'

class MyClassTest < Minitest::Test
  include Match
  Clause = Struct.new(:args, :function)

  def test_types
    lhs = Clause.new([String, Fixnum, Array, Symbol, Float, Hash, Proc], '')
    rhs = ["", 1, [], :hi, 1.1, {}, proc {}]
    assert match?(lhs, rhs)
  end

  def test_any_matching
    lhs = Clause.new([:any, 1, :any], '')
    rhs = ["dog", 1, 1.22]

    assert match?(lhs, rhs)
  end

  def test_literal_matching
    lhs = Clause.new([1, 2, 3], '')
    rhs = [1, 2, 3]
    rhs_fail = [2, 2, 4]

    assert match?(lhs, rhs)
    assert !match?(lhs, rhs_fail)
  end

  # array
  def test_array_matching
    lhs = Clause.new([1, [:any, Hash, 2], 3], '')
    rhs = [1, ["Dog", {people: ['Tom', 'Mary']}, 2], 3]

    assert match?(lhs, rhs)
  end

  def test_array_matching_2
    lhs = Clause.new([1, [[:any, [1]], Hash, 2], 3], '')
    rhs = [1, [[2, [1]], {people: ['Tom', 'Mary']}, 2], 3]
    rhs_fail = [1, [[2, [77]], {people: ['Tom', 'Mary']}, 2], 3]

    assert match?(lhs, rhs)
    assert !match?(lhs, rhs_fail)
  end

  def test_hash_matching
    lhs = Clause.new([{name: :any, friends: Array, home_phone: String}], '')
    rhs = [{name: "Jose", friends: ['Tim', 'Mary'], home_phone: '234-234-2343'}]
    rhs_fail = [{username: "Jose", friends: ['Tim', 'Mary'], home_phone: '234-234-2343'}]

    assert match?(lhs, rhs)
    assert !match?(lhs, rhs_fail)
  end

  def test_hash_destructuring
    lhs = Clause.new([{name: :any, friends: Array, home_phone: String}], '')
    rhs = [{name: "Jose", friends: ['Tim', 'Mary'], home_phone: '234-234-2343', fax_number: '11-1111-111'}]

    assert match?(lhs, rhs)
  end

  def test_compound_data_matching
    lhs = Clause.new([{name: :any, friends: Array, home_phone: String, homes: [:any, Array, {address: [String, "111 Gomer Pile"]}]}], '')
    rhs = [{name: "Jose", friends: ['Tim', 'Mary'], home_phone: '234-234-2343', homes: ["Big one", [1, 2 ,3], {address: ["Home", "111 Gomer Pile"]}], fax_number: '11-1111-111'}]

    assert match?(lhs, rhs)
  end
end
