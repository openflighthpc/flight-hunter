#==============================================================================
# Copyright (C) 2022-present Alces Flight Ltd.
#
# This file is part of Flight Hunter.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Hunter is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Hunter. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Hunter, please visit:
# https://github.com/openflighthpc/flight-hunter
#==============================================================================
require 'logger'

module TTY
  class Prompt
    class OrderedMultiList < MultiList
      def initialize(prompt, **options)
        super
        @logger = Logger.new("/home/jack/code/flight-hunter/log.log")
        @original = options[:original]

        @logger.info("STARTING_OGS: #{@original.map(&:name)}")
        @selected = OrderedSelectedChoices.new
        @editable = options[:edit_labels]
        @return_choices = options[:return_choices]
      end

      def render
        @prompt.print(@prompt.hide)
        until @done
          question = render_question
          @prompt.print(question)
          @prompt.read_keypress

          # Split manually; if the second line is blank (when there are no
          # matching lines), it won't be included by using String#lines.
          question_lines = question.split($INPUT_RECORD_SEPARATOR, -1)

          @prompt.print(refresh(question_lines_count(question_lines)))
        end
        @prompt.print(render_question) unless @quiet
        case !!@return_choices
        when false
          answer
        when true
          {
            choices: @choices,
            selected_choices: @selected,
            active_choice: choices[@active - 1]
          }
          # return the hash of choices
        end
      ensure
        @prompt.print(@prompt.show)
      end

      def keyspace(*)
        active_choice = choices[@active - 1]
        if @selected.include?(active_choice)
          @selected.delete(active_choice)
          @default.delete(active_choice.name)
          update_choices
        else
          if @editable
            @return_choices = true
            @done = true
          else
            return if @max && @selected.size >= @max

            @selected.insert(active_choice)
          end
        end
      end

      def update_choices
        new_choices = @choices.each_with_index.map do |choice, idx|
          if !@selected.any? { |c| c.name == choice.name }
            @original[idx]
          else
            choice
          end
        end

        @logger.info new_choices
        @choices = new_choices
      end

      def keyctrl_a(*)
        return if @max && @max < choices.size

        @selected = OrderedSelectedChoices.new(choices.enabled)
      end

      def keyctrl_r(*)
        super
        @selected = OrderedSelectedChoices.new(choices.enabled - @selected.to_a)
      end

      private

      def setup_defaults
        validate_defaults
        default_indexes = @default.map do |d|
          if d.to_s =~ INTEGER_MATCHER
            d - 1
          else
            choices.index(choices.find_by(:name, d.to_s))
          end
        end
        @selected = OrderedSelectedChoices.new(@choices.values_at(*default_indexes))

        if @default.empty?
          # no default, pick the first non-disabled choice
          @active = choices.index { |choice| !choice.disabled? } + 1
        elsif @default.last.to_s =~ INTEGER_MATCHER
          @active = @default.last
        elsif default_choice = choices.find_by(:name, @default.last.to_s)
          @active = choices.index(default_choice) + 1
        end
      end
    end

    class OrderedSelectedChoices
      include Enumerable

      attr_reader :selected

      def initialize(selected = [])
        @selected = selected
      end

      def index(choice)
        @selected.index(choice)
      end

      def clear
        @selected.clear
      end

      def size
        @selected.length
      end

      def each(&block)
        return to_enum unless block_given?

        @selected.each(&block)
      end

      def insert(choice)
        @selected << choice
        self
      end

      def replace(index, choice)
        to_replace = @selected[index]
        return nil unless to_replace
        @selected.insert(index, choice)
        delete(to_replace)
      end

      def delete(choice)
        found = @selected.include?(choice)
        return nil unless found
        @selected.delete(choice)
      end
    end
  end
end
