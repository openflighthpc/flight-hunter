# frozen_string_literal: true

module Hunter
  module Commands
    module NodeUtils
      class InvalidRangeError < StandardError; end

      def read_nodes(str)
        statements = str.split(',')

        collections = statements.map do |statement|
          # Expand bracket format
          expand_brackets(statement)
        end

        collections.reduce(:+).uniq
      end

      def expand_brackets(str)
        contents = str[/\[.*\]/]

        return [str] if contents.nil?

        left = str[/[^\[]*/]
        right = str[/].*/][1..-1]

        unless contents.match(/^\[[0-9]+-[0-9]+\]$/)
          raise InvalidRangeError, "'#{contents}' is not of the format [START-END]."
        end

        nums = contents[1..-2].split('-')

        unless nums.first.to_i <  nums.last.to_i
          raise InvalidRangeError, "'#{contents}' has a start index that is greater than its end index."
        end

        (nums.first..nums.last).map do |index|
          left + index + right
        end
      end
    end
  end
end
