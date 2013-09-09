module Wonga
  module Daemon
    class PantryImportAwsBillCommand
      def initialize(api_client, config)
        @api_client = api_client
        @config = config
        
        # check if there are hidden messages
        
        # if there are hidden messages wait for the next
        
        # otherwise create the first message to init the loop
        
      end

      def handle_message(message)
        p message.inspect
      end
    end
  end
end
