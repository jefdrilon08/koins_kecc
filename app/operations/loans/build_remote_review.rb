module Loans
  class BuildRemoteReview
    attr_reader :data

    def initialize(member:, loan:, loan_product:)
      @member       = member
      @loan         = loan
      @loan_product = loan_product

      @data = {
        loan: @loan,
        loan_product: @loan_product.name,
        payments: [],
        deductions: [],
        amount_released: @loan.principal
      }
    end

    def execute!
      @data[:payments]  = @loan.amortization_schedule_entries.map{ |o|
                            {
                              principal: o.principal,
                              interest: o.interest,
                              amount_due: o.amount_due
                            }
                          }

      loan_product_settings = Settings.loan_products.select{ |o| 
                                o.loan_product_id == @loan_product.id 
                              }.first

      cib_id  = Settings.branch_accounting_codes.select{ |o| 
                  o.branch_id == @member.branch_id 
                }.first.try(:cash_in_bank_accounting_code_id)

      if loan_product_settings.present? and loan_product_settings.amount_released_accounting_code_id.present?
        cib_id = loan_product_settings.amount_released_accounting_code_id
      end

      @data[:payments]  = @loan.amortization_schedule_entries.map{ |o|
                            {
                              principal: o.principal,
                              interest: o.interest,
                              amount_due: o.amount_due
                            }
                          }

      @data[:deductions]  = @loan.data[:accounting_entry][:credit_journal_entries].select{ |o|
                              o[:amount].to_f > 0 and o[:accounting_code_id] != cib_id
                            }.map{ |o|
                              {
                                name: o[:name],
                                amount: o[:amount].to_f
                              }
                            }

      @data[:deductions].each do |o|
        @data[:amount_released] -= o[:amount]
      end

      @data
    end
  end
end
