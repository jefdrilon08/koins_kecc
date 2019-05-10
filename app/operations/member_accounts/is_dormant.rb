module MemberAccounts
  class IsDormant
    def initialize(config:)
      @config = config

      @member_account   = @config[:member_account]
      @closing_date     = @config[:closing_date]
      @account_settings = @config[:account_settings]
      @account_type     = @member_account.account_type
      @account_subtype  = @member_account.account_subtype
      @member           = @member_account.member

      @dormant_threshold_months     = @account_settings.dormant_threshold_months
      @dormant_annual_interest_rate = @account_settings.dormant_annual_interest_rate || 0
      @annual_interest_rate         = @account_settings.annual_interest_rate
      @zero_interest_threshold      = @account_settings.zero_interest_threshold
      @monthly_interest_rate        = (@annual_interest_rate / 12.0)
    end

    def execute!
      # RULES: 
      # 1. if member has active loans, not dormant
      # 2. If member has no loans at all, dormant
      # 2. if member has no active loans
      if Loan.active.where(member_id: @member.id).count > 0
        return false
      elsif Loan.active.where(member_id: @member.id).count == 0
        last_paid_loan  = Loan.paid.where(
                            member_id: @member.id
                          ).order(
                            "date_completed ASC"
                          ).last

        if last_paid_loan.present?
          date_paid = last_paid_loan.date_paid

          threshold_date  = @closing_date - @dormant_threshold_months.to_i.months

          if date_paid < threshold_date
            return true
          else
            return false
          end
        else
          return true
        end
      end
    end
  end
end
