# frozen_string_literal: true

require_relative '../../node_list'

module Hunter
  module Commands
    module NodeUtils
      private

      def nodes_from_arg(arg)
        # Don't try and expand the brackets in a regular expression
        patterns = @options.regex ? arg.split(',') : cli_parser.expand(arg)
        node_fetcher.scan(patterns, regex: @options.regex)
      end

      def cli_parser
        @cli_parser ||= CLIParser.new
      end

      def node_fetcher
        @node_fetcher ||= NodeFetcher.new(buffer: @options.buffer)
      end

      def list
        node_fetcher.list
      end

      class InvalidRangeError < StandardError; end

      class CLIParser
        def expand(str)
          statements = str.split(',')

          collections = statements.map do |statement|
            # Expand bracket format
            expand_brackets(statement)
          end

          collections.reduce(:+).uniq.compact
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

      class NodeFetcher
        def initialize(buffer: false)
          case buffer
          when true
            @list = NodeList.load(Config.node_buffer)
            @search_field = :id
          else
            @list = NodeList.load(Config.node_list)
            @search_field = :label
          end
        end

        attr_reader :list
        attr_accessor :search_field

        def scan(arr, regex: false)
          case regex
          when true
            results = arr.map do |r|
              @list.select { |n| Regexp.new(r) =~ n.public_send(@search_field) }
            end
            results.reduce(:+).uniq.compact
          else
            arr.map { |n| @list.find(@search_field => n) }.compact
          end
        end
      end
    end
  end
end
