require 'spec_helper'
require_relative '../../pantry_import_aws_bill_command/pantry_import_aws_bill_command'

describe Wonga::Daemon::PantryImportAwsBillCommand do
  let(:api_client) { instance_double('Wonga::Daemon::PantryApiClient').as_null_object }
  let(:logger) { instance_double('Wonga::Daemon') }

  subject { described_class.new(api_client, logger).as_null_object }
  it_behaves_like 'handler'
  describe "#handle_message" do
    
  end
end

