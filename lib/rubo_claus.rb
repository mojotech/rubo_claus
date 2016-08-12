module RuboClaus
  Clause = Struct.new(:args, :function)
  CatchAll = Struct.new(:proc)

  module ClassMethods
    def define_function(symbol, &block)
      @function_name = symbol
      block.call
    end

    def clauses(*clauses)
      define_method(@function_name) do |*runtime_args|
        this_function = clauses.find do |pattern|
          match(pattern, runtime_args)
        end
        return this_function.function.call(*runtime_args) if this_function.is_a?(RuboClaus::Clause)
        return clauses[-1].proc.call if clauses[-1].proc
        raise NoMethodError
      end
    end

    def clause(args, function)
      Clause.new(args, function)
    end

    def catch_all(proc)
      CatchAll.new(proc)
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
    lhs.args.all? do |lhs_arg|
      rhs.all? do |rhs_arg|
        single_match(lhs_arg, rhs_arg)
      end
    end
  end
end
