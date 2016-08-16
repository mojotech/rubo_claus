require 'match'

module RuboClaus
  include Match
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
        if matching_function = find_matching_function(klauses, runtime_args)
          matching_function.call(*runtime_args)
        else
          raise NoPatternMatchError, "no pattern defined for: #{runtime_args}"
        end
      end
    end

    def clause(args, function)
      Clause.new(args, function)
    end

    def catch_all(_proc)
      CatchAll.new(_proc)
    end
  end

  private def find_matching_function(klauses, runtime_args)
    clause = klauses.find { |pattern| match?(pattern, runtime_args) }
    return clause.function if clause.is_a?(Clause)
    return clause.proc if clause.is_a?(CatchAll)
  end

  def self.included(klass)
    klass.extend ClassMethods
  end
end
