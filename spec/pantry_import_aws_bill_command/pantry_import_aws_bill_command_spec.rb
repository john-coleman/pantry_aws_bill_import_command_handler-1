require 'spec_helper'
require_relative '../../pantry_import_aws_bill_command/pantry_import_aws_bill_command'
require_relative '../../pantry_import_aws_bill_command/bill_parser'
require 'logger'

describe Wonga::Daemon::PantryImportAwsBillCommand do
  let(:publisher) { instance_double('Wonga::Publisher').as_null_object }
  let(:logger) { instance_double('Logger').as_null_object }
  let(:bucket) { instance_double('AWS::S3::Bucket').as_null_object }

  subject { described_class.new(publisher, bucket, logger, '1h').as_null_object }

  describe "#parse" do
    let(:bill_parser) { instance_double('Wonga::BillParser', parse: message) }
    let(:message) { { total: 10 } }
    let(:text) { 'some_text' }
    let(:object) { instance_double('AWS::S3::S3Object', read: text) }

    before(:each) do
      Wonga::BillParser.stub(:new).and_return(bill_parser)
      object.stub(:key).and_return("001100110011-aws-billing-csv-2013-08.csv")
    end

    it "publishes message with result" do
      bucket.stub(:objects).and_return([object])
      subject.parse
      expect(publisher).to have_received(:publish).with(message).twice
    end

    it "gets data from bill_parser" do
      bucket.stub(:objects).and_return([object])
      subject.parse
      expect(Wonga::BillParser).to have_received(:new).twice
      expect(bill_parser).to have_received(:parse).with(text).twice
    end

    it "loads last file from s3 bucket" do
      bucket.stub(:objects).and_return([object])
      subject.parse
      expect(object).to have_received(:read).twice
    end
    
    it "does not fail if there are no files" do
      bucket.stub(:objects).and_return([])
      subject.parse
      expect(object).to_not have_received(:read)
    end
  end
end
