require 'csv'
require 'bigdecimal'

module Wonga
  class BillParser
    def parse(text)
      result = {}
      ec2_costs = []

      CSV.parse(text[/InvoiceID.*/m], headers: true) do |row|
        if row["RecordType"] == "InvoiceTotal"
          result[:total_cost] = row["TotalCost"]
          result[:bill_date] = Time.parse(row["BillingPeriodEndDate"])
        end

        if row["user:pantry_request_id"]
          ec2_costs << {
            instance_id: row["user:pantry_request_id"],
            cost: BigDecimal(row["TotalCost"]),
            estimated: (row["InvoiceID"].strip == "Estimated")
          }
        end
      end

      grouped_costs = ec2_costs.group_by {|grouped_hash| grouped_hash[:instance_id]}
      result[:ec2_total] = grouped_costs.map {|key, value| { estimated: reduce_estimated(value), instance_id: key, cost: reduce_cost(value) }}
      result
    end

    def reduce_cost(value)
      value.map {|item| item[:cost]}.reduce(:+)
    end

    def reduce_estimated(value)
      value.map {|item| item[:estimated]}.any?
    end
  end
end

