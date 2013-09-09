require_relative 'bill_parser'

module Wonga
  module Daemon
    class PantryImportAwsBillCommand
      def initialize(api_client, logger)
        @api_client = api_client
        @logger = logger
        # check if there are hidden messages
        # if there are hidden messages wait for the next
        # otherwise create the first message to init the loop
      end

      def handle_message(message)
        parser = Wonga::BillParser.new

        read_file = ''
        result = parser.parse(read_file)
        logger.debug "Parsed #{result}"
        result
      end
    end
  end
end
