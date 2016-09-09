module RuboMethod

  def execute_clause(clause, runtime_args)
    case clause
    when RuboClaus::Clause
      execute(clause.function, runtime_args, clause.args)
    when RuboClaus::PrivateClause
      raise RuboClaus::NoPatternMatchError, "no pattern defined for: #{runtime_args}" unless @internal_call
      execute(clause.function, runtime_args, clause.args)
    when RuboClaus::CatchAll
      execute(clause.proc, runtime_args)
    else
      raise RuboClaus::NoPatternMatchError, "no pattern defined for: #{runtime_args}"
    end
  end

  def execute(proc, args, pattern=nil)
    args = head_tail_handle(pattern, args) if pattern
    @internal_call = true
    method = instance_exec *args, &proc
    @internal_call = false
    method
  end

  def head_tail_handle(lhs, rhs)
    lhs.each_with_index.flat_map do |arg, index|
      if arg.is_a?(Array) && arg.include?(:tail)
        number_of_heads = lhs[index][0..-2].size
        rhs[index][0..(number_of_heads - 1)] + [rhs[index][number_of_heads..-1]]
      else
        [rhs[index]]
      end
    end
  end
end
