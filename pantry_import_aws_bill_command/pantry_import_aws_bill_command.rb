module Wonga
  module Daemon
    class PantryImportAwsBillCommand
      def initialize(api_client, config)
        @api_client = api_client
        @config = config
      end

      def handle_message(message)
        #Put message handling code in here
      end
    end
  end
end
