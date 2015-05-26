require 'csv'
require 'bigdecimal'

module Wonga
  class BillParser
    def parse(text_stream)
      result = {}
      ec2_costs = []

      CSV.parse(text_stream, headers: true) do |row|
        if row['RecordType'] == 'InvoiceTotal'
          result[:total_cost] = row['TotalCost']
          result[:bill_date] = Time.parse(row['BillingPeriodEndDate'])
        end

        ec2_costs << row_to_cost_hash(row) if row['user:pantry_request_id']
      end

      result.merge(ec2_total: group_costs(ec2_costs))
    end

    private

    def group_costs(ec2_costs)
      grouped_costs = ec2_costs.group_by { |grouped_hash| grouped_hash[:instance_id] }
      grouped_costs.map do |instance_id, costs|
        {
          estimated: costs.any? { |cost| cost[:estimated] },
          instance_id: instance_id,
          cost: costs.inject(0) { |sum, item| sum + item[:cost] }
        }
      end
    end

    def row_to_cost_hash(row)
      {
        instance_id: row['user:pantry_request_id'],
        cost: BigDecimal(row['TotalCost']),
        estimated: (row['InvoiceID'].strip == 'Estimated')
      }
    end
  end
end
