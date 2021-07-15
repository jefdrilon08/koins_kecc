module Reports
	class InsuranceQuarterlyReports
		def initialize(start_date:, end_date:)
      @start_date       =  start_date.to_date
      @end_date         =  end_date.to_date
      
      if @start_date.present? && @end_date.present?
        @clip_member_accounts       = ReadOnlyMemberAccount.insurance.where(account_subtype: "Credit Life Insurance Plan")
        @hiip_member_accounts       = ReadOnlyMemberAccount.insurance.where(account_subtype: "Hospital Income Insurance Plan")

        @clip_account_trasactions   = ReadOnlyAccountTransaction.where("transacted_at >= ? AND transacted_at <= ? AND subsidiary_id IN (?)", @start_date, @end_date, @clip_member_accounts.ids)
        @hiip_account_trasactions   = ReadOnlyAccountTransaction.where("transacted_at >= ? AND transacted_at <= ? AND subsidiary_id IN (?)", @start_date, @end_date, @hiip_member_accounts.ids)
      end
    end

		def execute!
			@data = {}
      @data[:insurance] = []

      ins = {}

      ins[:clip_transactions_count] =  @clip_account_trasactions.count
      ins[:clip_total_amount] = @clip_account_trasactions.sum(:amount).to_f

      ins[:hiip_transactions_count] = @hiip_account_trasactions.count
      ins[:hiip_total_amount] = @hiip_account_trasactions.sum(:amount).to_f

      @data[:insurance] << ins

      @data 
		end
	end
end
