require 'match/rubo_array'
require 'match/rubo_hash'

module Match
  include RuboArray
  include RuboHash

  def match?(lhs, rhs)
    return true if lhs.is_a?(RuboClaus::CatchAll)
    return false if lhs.args.length != rhs.length
    any_match?(lhs.args, rhs)
  end

  def deep_match?(lhs, rhs)
    return match_array(lhs, rhs) if [lhs, rhs].all? { |side| side.is_a? Array }
    return match_hash(lhs, rhs) if [lhs, rhs].all? { |side| side.is_a? Hash }
    false
  end

  def single_match?(lhs, rhs)
    return true if lhs == :any
    return true if lhs == rhs
    return true if lhs == rhs.class
    false
  end

  def any_match?(lhs, rhs)
    return true if single_match?(lhs, rhs)
    deep_match?(lhs, rhs)
  end
end
