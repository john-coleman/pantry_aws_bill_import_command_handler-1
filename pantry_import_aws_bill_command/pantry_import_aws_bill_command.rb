require_relative 'bill_parser'

module Wonga
  module Daemon
    class PantryImportAwsBillCommand
      def initialize(publisher, bucket, logger)
        @publisher = publisher
        @logger = logger
        @bucket = bucket
      end

      def parse(all = false)
        files_to_parse = if all
                           filtered_files
                         elsif Date.today.day < 7
                           filtered_files.last(2)
                         else
                           filtered_files.last(1)
                         end

        files_to_parse.each { |file| process_s3_file(file) }
      end

      private

      def filtered_files
        @bucket.objects.select { |file| file.key =~ /aws-cost-allocation/ }
      end

      def process_s3_file(file)
        parser = Wonga::BillParser.new
        @logger.info { "Processing #{file.key}" }
        body_stream = file.get.body
        body_stream.readline
        result = parser.parse(body_stream)
        @logger.debug "Parsed #{result}"
        @publisher.publish(result)
        sleep 0.5
      end
    end
  end
end
