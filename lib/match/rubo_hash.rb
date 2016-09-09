module Match
  module RuboHash

    def match_hash(lhs, rhs)
      lhs, rhs = handle_destructuring(lhs, rhs) if lhs.keys.length < rhs.keys.length
      return false unless keys_match?(lhs, rhs)
      return false unless values_match?(lhs, rhs)
      true
    end

    def handle_destructuring(lhs, rhs)
      [lhs, rhs.select {|k, v| lhs.keys.include? k }]
    end

    def keys_match?(lhs, rhs)
      lhs.keys.sort == rhs.keys.sort
    end

    def values_match?(lhs, rhs)
      any_match?(lhs.values, rhs.values)
    end
  end
end

