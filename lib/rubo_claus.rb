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
        case matching_clause = find_matching_clause(klauses, runtime_args)
        when Clause
          instance_exec *head_tail_handle(matching_clause.args, runtime_args), &matching_clause.function
        when CatchAll
          instance_exec *runtime_args, &matching_clause.proc
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

  private def find_matching_clause(klauses, runtime_args)
    clause = klauses.find { |pattern| match?(pattern, runtime_args) }
    return clause if clause.is_a?(Clause) || clause.is_a?(CatchAll)
  end

  private def head_tail_handle(lhs, rhs)
    lhs.each_with_index.flat_map do |arg, index|
      if arg.is_a?(Array) && arg.include?(:tail)
        number_of_heads = lhs[index][0..-2].size
        rhs[index][0..(number_of_heads - 1)] + [rhs[index][number_of_heads..-1]]
      else
        [rhs[index]]
      end
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
  end
end
