require 'spec_helper'
require_relative '../../pantry_import_aws_bill_command/bill_parser'

describe Wonga::BillParser do
  context "parse bill" do
    before(:each) { @result = subject.parse IO.read("spec/fixtures/bill.csv") }

    it "parses the total cost and billing date" do
      expect(@result[:total_cost]).to eq("10801.86")
      expect(@result[:bill_date]).to eq(Time.new(2013, 9, 30, 23, 59, 59))
    end

    it "parses a non estimated instance" do
      expect(@result[:ec2_total][0][:instance_id]).to eq("1")
      expect(@result[:ec2_total][0][:cost]).to eq(BigDecimal('3.197992'))
      expect(@result[:ec2_total][0][:estimated]).to be_false
    end

    it "parses the estimated instance" do
      expect(@result[:ec2_total][1][:instance_id]).to eq("2")
      expect(@result[:ec2_total][1][:cost]).to eq(BigDecimal('4.477198'))
      expect(@result[:ec2_total][1][:estimated]).to be_true
    end
  end
end
