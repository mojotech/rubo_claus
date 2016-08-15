module Match
  def deep_match?(lhs, rhs)
    return false unless [lhs, rhs].all? { |side| side.is_a? Array }
    lhs.zip(rhs) { |array| return false unless single_match?(*array) } || true
  end

  def single_match?(lhs, rhs)
    return true if lhs == :any
    return true if lhs == rhs
    return true if lhs == rhs.class
    deep_match?(lhs, rhs)
  end

  def match?(lhs, rhs)
    return true if lhs.is_a?(RuboClaus::CatchAll)
    return false if lhs.args.length != rhs.length
    deep_match?(lhs.args, rhs)
  end
end
