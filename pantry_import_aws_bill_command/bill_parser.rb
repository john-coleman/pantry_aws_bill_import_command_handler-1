require 'csv'
require 'bigdecimal'

module Wonga
  class BillParser
    def parse(text)
      result = {}
      result[:ec2] = []
      
      CSV.parse(text[/InvoiceID.*/], headers: true) do |row|
        if row["RecordType"] == "InvoiceTotal"
          result[:total_cost] = row["TotalCost"]
          result[:bill_date] = Time.parse(row["BillingPeriodEndDate"])
        end

        if row["user:pantry_request_id"]
          result[:ec2] << {
            instance_id: row["user:pantry_request_id"],
            cost: BigDecimal.new(row["TotalCost"]),
            estimated: (row["InvoiceID"].strip == "Estimated")
          }
        end
      end
      
      grouped_costs = result[:ec2].group_by {|grouped_hash| grouped_hash[:instance_id]}
      result[:ec2_total] = grouped_costs.map {|key, value| {estimated: reduce_estimated(value), instance_id: key, cost: BigDecimal.new(reduce_cost(value), 2)}}
      result
    end
    
    def reduce_cost(value)
      value.map {|item| item[:cost]}.reduce(:+)
    end
    
    def reduce_estimated(value)
      value.map {|item| item[:estimated]}.first
    end
  end
end

