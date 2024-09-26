module Members
  class Reinstate
    def initialize(member:, reinstatement_date:, reinstate_by:, date_stop:)
      @member                   = member
      @recognition_date         = @member.recognition_date.try(:to_date)
      @member_account           = @member.member_accounts
      @member_life_account      = @member_account.where(account_subtype: "Life Insurance Fund").last
      @member_rf_account        = @member_account.where(account_subtype: "Retirement Fund").last
      @current_balance_life     = @member_life_account.balance.to_i #get life balance
      @current_balance_rf       = @member_rf_account.balance.to_i #get rf balance
      @current_balance          = @current_balance_life + @current_balance_rf #combine to get total of 20 pesos per week contribution
      @current_date             = Date.today
      @num_days                 = (@current_date - @recognition_date).to_i
      @num_weeks                = (@num_days / 7).to_i + 1
      @insured_amount_life      = @num_weeks  * 15 # compute insured amount life
      @insured_amount_rf        = @num_weeks  * 5 # compute insured amount rf
      @insured_amount           = @insured_amount_life + @insured_amount_rf # combine to get total insured amount for life and rf
      @amt_past_due             = (@current_balance - @insured_amount) * -1 # total amount past due for life and RF combined
      @num_weeks_past_due       = (@amt_past_due / 20).to_i # divide to 20 to get weeks lapsed
      @amount_to_paid           = @amt_past_due + 20 # add 20 pesos for 1 week payment
      @reinstatement_date       = reinstatement_date
      @reinstate_by             = reinstate_by
      @member_data              = @member.data.with_indifferent_access
    
      @member_data[:reinstatement] = {}
    end

    def execute!
      @member_data[:reinstatement][:reinstatement_date] = @reinstatement_date
      @member_data[:reinstatement][:num_weeks_past_due] = @num_weeks_past_due
      @member_data[:reinstatement][:amount_to_paid] = @amount_to_paid
      @member_data[:reinstatement][:reinstate_by] = @reinstate_by
      @member_data[:reinstatement][:date_reinstated] = Date.today
      @member_data[:reinstatement][:old_recognition_date] = @recognition_date
      @member_data[:reinstatement][:is_reinstated] = true

      @member.update!(data: @member_data)

      membership_payment = @member.membership_payment_records.where(membership_type: "Insurance", membership_name: "K-MBA").order("date_paid ASC").last

      if membership_payment.present?
        membership_payment.update!(date_paid: @reinstatement_date)
      end
    end
  end
end