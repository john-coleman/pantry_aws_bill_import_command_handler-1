require_relative 'bill_parser'

module Wonga
  module Daemon
    class PantryImportAwsBillCommand
      def initialize(publisher, bucket, logger)
        @publisher = publisher
        @logger = logger
        @bucket = bucket
      end

      def parse(all=false)
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
        @bucket.objects.each_with_object([]) do |file, filtered|
          filtered << file if file.key =~ /aws-cost-allocation/
        end
      end

      def process_s3_file(file)
        parser = Wonga::BillParser.new
        @logger.info { "Processing #{file.key}" }
        result = parser.parse(file.read)
        @logger.debug "Parsed #{result}"
        @publisher.publish(result)
      end
    end
  end
end
