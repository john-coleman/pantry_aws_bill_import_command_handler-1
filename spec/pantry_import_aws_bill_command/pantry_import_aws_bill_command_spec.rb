require 'spec_helper'
require_relative '../../pantry_import_aws_bill_command/pantry_import_aws_bill_command'
require_relative '../../pantry_import_aws_bill_command/bill_parser'
require 'logger'

describe Wonga::Daemon::PantryImportAwsBillCommand do
  let(:publisher) { instance_double('Wonga::Publisher').as_null_object }
  let(:logger) { instance_double('Logger').as_null_object }
  let(:bucket) { instance_double('AWS::S3::Bucket').as_null_object }

  subject { described_class.new(publisher, bucket, logger).as_null_object }

  describe "#parse" do
    let(:bill_parser) { instance_double('Wonga::BillParser', parse: message) }
    let(:message) { { total: 10 } }
    let(:text) { 'some_text' }
    let(:object) { instance_double('AWS::S3::S3Object', read: text, key: "001100110011-aws-cost-allocation-2013-08.csv") }
    let(:bad_object) { instance_double('AWS::S3::S3Object', key: "bad_object") }

    before(:each) do
      Wonga::BillParser.stub(:new).and_return(bill_parser)
    end

    it "publishes message with result" do
      bucket.stub(:objects).and_return([object])
      subject.parse
      expect(publisher).to have_received(:publish).with(message)
    end

    it "gets data from bill_parser" do
      bucket.stub(:objects).and_return([object])
      subject.parse
      expect(Wonga::BillParser).to have_received(:new)
      expect(bill_parser).to have_received(:parse).with(text)
    end

    describe "in the beginning of month" do
      it "loads 2 last files with corresponding name from s3 bucket by default" do
        Date.stub_chain(:today, :day).and_return(2)
        bucket.stub(:objects).and_return([object, bad_object, object])
        subject.parse
        expect(bill_parser).to have_received(:parse).with(text).twice
      end
    end

    describe "in the end of month" do
      it "loads last file with corresponding name from s3 bucket by default" do
        Date.stub_chain(:today, :day).and_return(25)
        bucket.stub(:objects).and_return([object, bad_object, object])
        subject.parse
        expect(bill_parser).to have_received(:parse).with(text).once
      end
    end

    it "does not fail if there are no files with corresponding name" do
      bucket.stub(:objects).and_return([bad_object])
      subject.parse
      expect(bill_parser).to_not have_received(:parse)
      expect(publisher).to_not have_received(:publish).with(message)
    end

    it "parses all filtered files if requested" do
      bucket.stub(:objects).and_return([object, object, object])
      subject.parse(true)
      expect(bill_parser).to have_received(:parse).with(text).exactly(3).times
    end
  end
end
