require 'match'
require 'rubo_method'

module RuboClaus
  include Match
  include RuboMethod

  Clause = Struct.new(:args, :function)
  PrivateClause = Struct.new(:args, :function)
  CatchAll = Struct.new(:proc)

  class NoPatternMatchError < NoMethodError; end

  module ClassMethods
    def define_function(symbol, &block)
      @function_name = symbol
      block.call
    end

    def clauses(*klauses)
      define_method(@function_name) do |*runtime_args|
        matching_clause = find_matching_clause(klauses, runtime_args)
        execute_clause(matching_clause, runtime_args)
      end
    end

    def clause(args, function)
      Clause.new(args, function)
    end

    def p_clause(args, function)
      PrivateClause.new(args, function)
    end

    def catch_all(_proc)
      CatchAll.new(_proc)
    end
  end

  private def find_matching_clause(klauses, runtime_args)
    clause = klauses.find { |pattern| match?(pattern, runtime_args) }
    return clause if [Clause, PrivateClause, CatchAll].include?(clause.class)
  end

  def self.included(klass)
    klass.extend ClassMethods
  end
end
