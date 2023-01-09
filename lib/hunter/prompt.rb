require_relative './ordered_multi_list.rb'

module TTY
  class Prompt
    def ordered_multi_select(question, *args, &block)
      invoke_select(OrderedMultiList, question, *args, &block)
    end
  end
end
