# frozen_string_literal: true

module Rien
  module Const
    COMPILE_OPTION = {
      inline_const_cache: true,
      instructions_unification: true,
      operands_unification: true,
      peephole_optimization: true,
      specialized_instruction: true,
      stack_caching: true,
      tailcall_optimization: true,
      trace_instruction: false
    }.freeze
  end
end
