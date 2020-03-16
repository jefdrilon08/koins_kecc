module Insights
  class FetchPortfolio
    attr_accessor :start_date,
                  :end_date,
                  :interval,
                  :dates,
                  :branch,
                  :data

    def initialize(start_date:, end_date:, interval:, branch: nil)
      self.start_date = start_date
      self.end_date   = end_date
      self.interval   = interval
      self.branch     = branch

      self.dates  = []

      self.data = {
        records: []
      }
    end

    def execute!
      if interval == "daily"
        self.dates  = (start_date..end_date).to_a
      elsif interval == "weekly"
        d = start_date
        ((self.end_date - self.start_date).to_i / 7).times do
          self.dates << d
          d = d + 7.days
        end
      elsif interval == "monthly"
        d = start_date
        ((self.end_date - self.start_date).to_i / 30).times do
          self.dates << d
          d = d + 1.month
        end
      else
        raise "Invalid interval #{interval}"
      end

      data_stores = DataStore.select(
                      "id, data->>'total_overall_principal_balance' AS portfolio, data->'branch'->>'id' AS branch_id"
                    ).where(
                      "DATE(data->>'as_of') IN (?)",
                      dates
                    )

      if branch.present?
        data_stores = data_stores.where("data->'branch'->>'id' = ?", branch.id)
      end

      data[:records]  = data_stores.map{ |o|
                          {
                            portfolio: o.fetch("portfolio")
                          }
                        }
    end
  end
end
