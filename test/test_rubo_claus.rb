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

  define_function :print_string_in_array do
    clauses(
      clause([1, [:any, [String]], Fixnum], proc { |n, n1, n2| "#{n1[1][0]}" })
    )
  end

  define_function :integer_in_nested_array do
    clauses(
      clause([Fixnum, 2, [[[[[Fixnum]]]]]], proc { |n, n1, n2| n2[0][0][0][0][0] })
    )
  end

  define_function :hash_keys do
    clauses(
      clause([Hash], proc { |hash| hash.keys })
    )
  end

  define_function :friend_hash do
    clauses(
      clause([{friend: String, foe: :any}], proc { |n| "I know #{n[:friend]}" })
    )
  end

  define_function :friend_hash_des do
    clauses(
      clause([{friend: String}], proc { |n| "I know everything about #{n[:friend]}" })
    )
  end

  define_function :get_people do
    clauses(
      clause([:any, [1, 2, String, String], {people: String}], proc { |n, n1, n2| n2[:people] })
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

  def test_nested_array_with_shape
    k = MyClass.new

    assert_equal "Inner string", k.print_string_in_array(1, [1, ["Inner string"]], 3)

    assert_raises RuboClaus::NoPatternMatchError do
      k.print_string_in_array(3, [1, "Inner string"], 3)
    end

    assert_raises RuboClaus::NoPatternMatchError do
      k.print_string_in_array(3, [1, "Inner string"], "S")
    end

    assert_raises RuboClaus::NoPatternMatchError do
      k.print_string_in_array(3, [1, []], "S")
    end

    assert_raises RuboClaus::NoPatternMatchError do
      k.print_string_in_array(3, [[]], "S")
    end
  end

  def test_nested_array
    k = MyClass.new

    assert_equal 3, k.integer_in_nested_array(1, 2, [[[[[3]]]]])

    assert_raises RuboClaus::NoPatternMatchError do
      k.integer_in_nested_array(1, 2, [[[[["Dog"]]]]])
    end
  end

  def test_hash
    k = MyClass.new

    assert_equal [:dog], k.hash_keys({dog: :bone})

    assert_raises RuboClaus::NoPatternMatchError do
      k.hash_keys([{}])
    end
  end

  def test_hash_with_keys
    k = MyClass.new

    assert_equal "I know John", k.friend_hash({friend: "John", foe: 3})

    assert_raises RuboClaus::NoPatternMatchError do
      k.friend_hash({})
    end
  end

  def test_hash_with_keys_destructured
    k = MyClass.new

    assert_equal "I know everything about John", k.friend_hash_des({friend: "John", foe: 3})

    assert_raises RuboClaus::NoPatternMatchError do
      k.friend_hash_des({})
    end
  end

  def test_compound_hash_array
    k = MyClass.new

    assert_equal "John", k.get_people("Douglas", [1, 2, "Anything", "Another any string"], {people: "John"})

    assert_raises RuboClaus::NoPatternMatchError do
      k.get_people("Douglas", [], {people: "John"})
    end
  end

  def test_three_dimensional_compound_data_structure
    k = MyClass.new

    param = {username: "Sally Moe", friends: [], phone: {fax: "NA", mobile: "123-345-1232", emergency: {day: "123-123-1234", night: "999-999-9999"}}}
    assert_equal "999-999-9999", k.night_emergency_phone(param)

    assert_raises RuboClaus::NoPatternMatchError do
      param = {username: "Sally Moe", friends: "", phone: {fax: "NA", mobile: "123-345-1232", emergency: [{day: "123-123-1234", night: "999-999-9999"}]}}
      k.night_emergency_phone(param)
    end
  end
end
