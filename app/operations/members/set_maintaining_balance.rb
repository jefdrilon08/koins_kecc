module Members
  class SetMaintainingBalance
    def initialize(config:)
      @config = config
      @member = @config[:member]

      @active_loans = Loan.active.where(
                        member_id: @member.id
                      )

      @member_accounts  = @member.member_accounts

      @settings_loan_products = Settings.loan_products
    end

    def execute!
      @settings_loan_products.each do |s|
        if s.maintaining_balance.present?
          member_account  = @member_accounts.select{ |o| 
                              o.account_type == s.maintaining_balance.account_type and o.account_subtype == s.maintaining_balance.account_subtype 
                            }.first

          if member_account.present?
            maintaining_balance = 0.00
            
            @active_loans.where(loan_product_id: s.loan_product_id).each do |loan|
              if s.maintaining_balance.threshold.present? and loan.principal >= s.maintaining_balance.threshold.to_f.round(2)
                maintaining_balance += (loan.principal * s.maintaining_balance.percentage)
              end
            end

            member_account.update!(maintaining_balance: maintaining_balance.round(2))
          end
        end
      end
    end
  end
end
