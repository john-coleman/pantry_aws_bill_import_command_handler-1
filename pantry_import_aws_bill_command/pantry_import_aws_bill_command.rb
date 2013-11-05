require_relative 'bill_parser'
require 'rufus-scheduler'

module Wonga
  module Daemon
    class PantryImportAwsBillCommand
      def initialize(publisher, bucket, logger, job_interval)
        @publisher = publisher
        @logger = logger
        @bucket = bucket
        @job_interval = job_interval
        parse
        
        Rufus::Scheduler.new.in @job_interval do
          parse
        end
      end
      
      def parse
        filtered = []
        @bucket.objects.each do |file|
          filtered << file if file.key =~ /aws-billing-csv/
        end

        if filtered.last
          parser = Wonga::BillParser.new
          @logger.info { "Last file is #{filtered.last.key}" }
          result = parser.parse(filtered.last.read)
          @logger.debug "Parsed #{result}"
          @publisher.publish(result)
        end
      end
    end
  end
end
