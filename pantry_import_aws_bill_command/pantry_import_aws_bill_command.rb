require_relative 'bill_parser'

module Wonga
  module Daemon
    class PantryImportAwsBillCommand
      def initialize(bucket, api_client, logger)
        @api_client = api_client
        @logger = logger
        @bucket = bucket
        # check if there are hidden messages
        # if there are hidden messages wait for the next
        # otherwise create the first message to init the loop
      end

      def handle_message(message)
        parser = Wonga::BillParser.new

        @logger.info { "Last file is #{@bucket.objects.to_a.last.key}" }
        result = parser.parse(@bucket.objects.to_a.last.read)
        @logger.debug "Parsed #{result}"
        result
      end
    end
  end
end
