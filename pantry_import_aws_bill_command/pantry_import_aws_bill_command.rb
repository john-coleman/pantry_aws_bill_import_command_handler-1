require_relative 'bill_parser'

module Wonga
  module Daemon
    class PantryImportAwsBillCommand
      def initialize(publisher, bucket, logger)
        @publisher = publisher
        @logger = logger
        @bucket = bucket
      end

      def handle_message(message)
        parser = Wonga::BillParser.new

        @logger.info { "Last file is #{@bucket.objects.to_a.last.key}" }
        result = parser.parse(@bucket.objects.to_a.last.read)
        @logger.debug "Parsed #{result}"
        @publisher.publish(result) # continue the loop
      end
    end
  end
end
