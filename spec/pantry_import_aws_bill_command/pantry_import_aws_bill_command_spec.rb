require 'spec_helper'
require_relative '../../pantry_import_aws_bill_command/pantry_import_aws_bill_command'
require_relative '../../pantry_import_aws_bill_command/bill_parser'
require 'logger'

describe Wonga::Daemon::PantryImportAwsBillCommand do
  def send_message(msg, queue_name = 'pantry_test_import_aws_bill_command')
    sqs = AWS::SQS.new
    url = sqs.queues.url_for(queue_name)
    sqs.queues[url].send_message(msg.to_json)
  end
  
  let(:publisher) { instance_double('Wonga::Daemon').as_null_object }
  let(:api_client) { instance_double('Wonga::Daemon::PantryApiClient').as_null_object }
  let(:logger) { instance_double('Logger').as_null_object }
  let(:bucket) { instance_double('AWS::S3::Bucket').as_null_object }

  subject do 
    Wonga::Daemon.stub(:config).and_return('pantry_test_import_aws_bill_command')
    described_class.new(publisher, bucket, api_client, logger).as_null_object
  end

  it_behaves_like 'handler'

  describe "#handle_message" do
    let(:bill_parser) { instance_double('Wonga::BillParser').as_null_object }
    let(:message) { {"process" => true} }
    let(:text) { 'some_text' }
    let(:object) { instance_double('AWS::S3::S3Object', read: text) }

    before(:each) do
      Wonga::BillParser.stub(:new).and_return(bill_parser)
      bucket.stub(:objects).and_return([object])
    end
    
    it "sends a message to the queue" do
      
    end

    it "gets data from bill_parser" do
      subject.handle_message(message)
      expect(Wonga::BillParser).to have_received(:new)
      expect(bill_parser).to have_received(:parse).with(text)
    end

    it "loads last file from s3 bucket" do
      subject.handle_message(message)
      expect(object).to have_received(:read)
    end
  end
end
