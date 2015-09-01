require 'spec_helper'
require 'wonga/daemon/publisher'
require_relative '../../pantry_import_aws_bill_command/pantry_import_aws_bill_command'
require 'logger'

RSpec.describe Wonga::Daemon::PantryImportAwsBillCommand do
  let(:publisher) { instance_double(Wonga::Daemon::Publisher).as_null_object }
  let(:logger) { instance_double(Logger).as_null_object }
  let(:bucket) { instance_double(Aws::S3::Bucket, objects: objects).as_null_object }

  subject { described_class.new(publisher, bucket, logger) }

  describe '#parse' do
    let(:bill_parser) { instance_double(Wonga::BillParser, parse: message) }
    let(:message) { { total: 10 } }
    let(:text) do
      io = StringIO.new
      allow(io).to receive(:readline)
      io
    end

    let(:object) { instance_double(Aws::S3::ObjectSummary, get: double(body: text), key: '001100110011-aws-cost-allocation-2013-04.csv') }
    let(:bad_object) { instance_double(Aws::S3::ObjectSummary, key: 'bad_object') }
    let(:objects) { [object] }

    before(:each) do
      allow(Wonga::BillParser).to receive(:new).and_return(bill_parser)
      allow(subject).to receive(:sleep)
    end

    it 'publishes message with result' do
      allow(bucket).to receive(:objects).and_return([object])
      subject.parse
      expect(publisher).to have_received(:publish).with(message)
    end

    it 'gets data from bill_parser' do
      allow(bucket).to receive(:objects).and_return([object])
      subject.parse
      expect(Wonga::BillParser).to have_received(:new)
      expect(bill_parser).to have_received(:parse).with(text)
      expect(text).to have_received(:readline)
    end

    context 'when there are several good objects' do
      let(:objects) { [object, object, bad_object, object] }

      describe 'in the beginning of month' do
        before(:each) { allow(Date).to receive_message_chain(:today, :day).and_return(2) }

        it 'loads 2 last files with corresponding name from s3 bucket by default' do
          allow(Date).to receive_message_chain(:today, :day).and_return(2)
          subject.parse
          expect(bill_parser).to have_received(:parse).with(text).twice
        end
      end

      describe 'in the end of month' do
        before(:each) { allow(Date).to receive_message_chain(:today, :day).and_return(25) }

        it 'loads last file with corresponding name from s3 bucket by default' do
          subject.parse
          expect(bill_parser).to have_received(:parse).with(text).once
        end
      end

      it 'parses all filtered files if requested' do
        subject.parse(true)
        expect(bill_parser).to have_received(:parse).with(text).exactly(3).times
      end
    end

    context 'when there are no files with corresponding name' do
      let(:objects) { [bad_object] }

      it 'does not fail if there are no files with corresponding name' do
        subject.parse
        expect(bill_parser).to_not have_received(:parse)
        expect(publisher).to_not have_received(:publish).with(message)
      end
    end
  end
end
