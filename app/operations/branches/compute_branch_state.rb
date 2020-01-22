module Branches
  class ComputeBranchState
    def initialize(config:)
      @config = config

      @branch   = @config[:branch]
      @as_of    = @config[:as_of].try(:to_date) || Date.today
      @cluster  = @branch.cluster
      @area     = @cluster.area

      @data = {
        as_of: @as_of,
        num_loans: 0,
        num_members: 0,
        principal: 0.00,
        interest: 0.00,
        repayment_rate: nil,
        par: nil,
        principal_repayment_rate: nil,
        interest_repayment_rate: nil,
        total_principal_due: 0.00,
        total_interest_due: 0.00,
        total_due: 0.00,
        total_principal_balance: 0.00,
        total_interest_balance: 0.00,
        total_balance: 0.00,
        total_principal_portfolio: 0.00,
        total_interest_portfolio: 0.00,
        total_portfolio: 0.00,
        total_principal_paid: 0.00,
        total_interest_paid: 0.00,
        total_paid: 0.00,
        total_principal_paid_due: 0.00,
        total_interest_paid_due: 0.00,
        total_paid_due: 0.00,
        total_principal_past_due: 0.00,
        total_interest_past_due: 0.00,
        total_past_due: 0.00,
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        cluster: {
          id: @cluster.id,
          name: @cluster.name
        },
        area: {
          id: @area.id,
          name: @area.name
        },
        loan_products: []
      }
    end

    def execute!
      query!
      build_loan_products!
    end

    def build_loan_products!
      @data[:loan_products] = @cmd.data[:records].group_by{ |o| o[:loan_product] }.map{ |loan_product, records|
                                principal = records.inject(0) { |sum, hash| sum + hash[:principal] }.to_f.round(2)
                                interest  = records.inject(0) { |sum, hash| sum + hash[:interest] }.to_f.round(2)

                                total_principal_due = 0.00
                                total_interest_due  = 0.00
                                total_due           = (total_principal_due + total_interest_due).round(2)

                                total_principal_balance = 0.00
                                total_interest_balance  = 0.00
                                total_balance           = (total_principal_balance + total_interest_balance).to_f.round(2)

                                {
                                  as_of: @as_of,
                                  num_loans: records.size,
                                  num_members: records.map{ |o| o[:member][:id] }.uniq.size,
                                  principal: principal,
                                  interest: interest,
                                  repayment_rate: nil,
                                  par: nil,
                                  principal_repayment_rate: nil,
                                  interest_repayment_rate: nil,
                                  total_principal_due: 0.00,
                                  total_interest_due: 0.00,
                                  total_due: 0.00,
                                  total_principal_balance: 0.00,
                                  total_interest_balance: 0.00,
                                  total_balance: 0.00,
                                  total_principal_portfolio: 0.00,
                                  total_interest_portfolio: 0.00,
                                  total_portfolio: 0.00,
                                  total_principal_paid: 0.00,
                                  total_interest_paid: 0.00,
                                  total_paid: 0.00,
                                  total_principal_paid_due: 0.00,
                                  total_interest_paid_due: 0.00,
                                  total_paid_due: 0.00,
                                  total_principal_past_due: 0.00,
                                  total_interest_past_due: 0.00,
                                  total_past_due: 0.00,
                                  loan_product: {
                                    id: loan_product[:id],
                                    name: loan_product[:name]
                                  },
                                  loans: records
                                }
                              }
    end

    def query!
      @cmd  = ::Branches::ComputeRr.new(
                config: {
                  branch: @branch,
                  as_of: @as_of
                }
              )

      @cmd.execute!
    end
  end
end
