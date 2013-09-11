require 'csv'

module Wonga
  class BillParser
    def parse(text)
      result = {}
      CSV.parse(text, headers: true) do |row|
        if row["RecordType"] == "InvoiceTotal"
          result[:total_cost] = row["TotalCost"]
          result[:bill_date] = Time.parse(row["BillingPeriodEndDate"])
        end
      end
      result
    end
  end
end

