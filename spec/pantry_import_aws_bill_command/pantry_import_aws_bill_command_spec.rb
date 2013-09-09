require 'spec_helper'
require_relative '../../pantry_import_aws_bill_command/pantry_import_aws_bill_command'

describe Wonga::Daemon::PantryImportAwsBillCommand do
  it_behaves_like 'handler'
  describe "#handle_message" do
    #add in unit test code for handle message here.
  end
end

