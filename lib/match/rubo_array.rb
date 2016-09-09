module Match
  module RuboArray

    def match_array(lhs, rhs)
      return head_tail_destructuring_match(lhs, rhs) if lhs.include?(:tail)
      return false if lhs.length != rhs.length
      lhs.zip(rhs) { |array| return false unless any_match?(*array) } || true
    end

    def head_tail_destructuring_match(lhs, rhs)
      any_match?(lhs[0..-2], rhs[0..(lhs[0..-2].size - 1)])
    end
  end
end
