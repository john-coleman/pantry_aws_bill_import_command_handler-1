require_relative 'bill_parser'

module Wonga
  module Daemon
    class PantryImportAwsBillCommand
      def initialize(publisher, bucket, api_client, logger)
        @publisher = publisher
        @api_client = api_client
        @logger = logger
        @bucket = bucket
        @publisher.publish({"process" => true})
      end

      def handle_message(message)
        if message["process"]
          parser = Wonga::BillParser.new

          @logger.info { "Last file is #{@bucket.objects.to_a.last.key}" }
          result = parser.parse(@bucket.objects.to_a.last.read)
          @logger.debug "Parsed #{result}"
          @publisher.publish({"process" => true}) # continue the loop
          result
        end
      end
      
      def send_message
        sqs = AWS::SQS.new
        url = sqs.queues.url_for(Wonga::Daemon.config['sqs']['queue_name'])
        $stdout.puts sqs.queues[url].send_message({"process" => true}.to_json)
      end
    end
  end
end
