require 'spec_helper'
require_relative '../../pantry_import_aws_bill_command/bill_parser'

describe Wonga::BillParser do
  context "parse bill" do
    it "parse" do
      result = subject.parse IO.read("spec/fixtures/bill.csv")
      expect(result[:total_cost]).to eq("2772.11")
      expect(result[:bill_date]).to eq(Time.new(2013, 8, 31, 23, 59, 59))
    end
  end
end
