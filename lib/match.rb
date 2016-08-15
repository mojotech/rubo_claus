module Match
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

  def match?(lhs, rhs)
    return true if lhs.is_a?(RuboClaus::CatchAll)
    return false if lhs.args.length != rhs.length
    any_match?(lhs.args, rhs)
  end

  def any_match?(lhs, rhs)
    return true if single_match?(lhs, rhs)
    deep_match?(lhs, rhs)
  end

  private def match_array(lhs, rhs)
    return false if lhs.length != rhs.length
    lhs.zip(rhs) { |array| return false unless any_match?(*array) } || true
  end

  private def match_hash(lhs, rhs)
    lhs, rhs = handle_destructuring(lhs, rhs) if lhs.keys.length < rhs.keys.length
    return false unless keys_match?(lhs, rhs)
    return false unless values_match?(lhs, rhs)
    true
  end

  private def handle_destructuring(lhs, rhs)
    [lhs, rhs.select {|k, v| lhs.keys.include? k }]
  end

  private def keys_match?(lhs, rhs)
    lhs.keys.sort == rhs.keys.sort
  end

  private def values_match?(lhs, rhs)
    any_match?(lhs.values, rhs.values)
  end
end
