module RuboClaus
  Clause = Struct.new(:args, :function)
  CatchAll = Struct.new(:proc)

  class NoPatternMatchError < NoMethodError; end

  module ClassMethods
    def define_function(symbol, &block)
      @function_name = symbol
      block.call
    end

    def clauses(*klauses)
      define_method(@function_name) do |*runtime_args|
        this_function = klauses.find { |pattern| match(pattern, runtime_args) }

        return this_function.function.call(*runtime_args) if this_function.is_a?(Clause)
        return klauses[-1].proc.call if klauses[-1].is_a?(CatchAll)
        raise NoPatternMatchError
      end
    end

    def clause(args, function)
      Clause.new(args, function)
    end

    def catch_all(_proc)
      CatchAll.new(_proc)
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
  end

  private def single_match(lhs, rhs)
    return true if lhs == :any
    return true if lhs == rhs
    return true if lhs == rhs.class
    false
  end

  private def match(lhs, rhs)
    return true if lhs.is_a?(RuboClaus::CatchAll)
    return false if lhs.args.length != rhs.length
    lhs.args.zip(rhs) { |array| return false unless single_match(array[0], array[1]) }
    true
  end
end
