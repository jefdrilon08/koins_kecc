module Pages
  class InsuranceAccountStatusReports
    def initialize(branch:, insurance_status:)
      @branch     = branch
      @insurance_status = insurance_status
      @centers    = Center.where(branch_id: @branch).order("name ASC")
    end

    def execute!
      @data           = {}
      @data[:centers] = []
      @data[:members] = []

      @centers.each_with_index do |center|
        member_center = {}
        member_center[:center]    = center.to_s
        member_center[:members]   = []
        @members = ReadOnlyMember.active_and_resigned.where(center_id: center.id).order("last_name ASC")

        if @insurance_status.present?
          @members = @members.where(insurance_status: @insurance_status)
        end

        if @members.count > 0
          @members.each_with_index do |member, i|
            recognition_date  = member.data['recognition_date']
            current_date = Date.today
            member_record = {}

            if recognition_date.present? and member.lif_amount != 0
              #rf compute
              @rf_default = 5
              @rf_account  = ReadOnlyMemberAccount.where(account_subtype: "Retirement Fund", member_id: member.id).sum(:balance)
              @rf_coverage = (recognition_date.to_date + (@rf_account.to_i / @rf_default.to_i).weeks).strftime("%Y-%m-%d")
              @rf_num_days   = current_date.to_date - recognition_date.to_date
              @rf_num_weeks  = (@rf_num_days.to_i / 7) + 1
              @rf_insured_amount    = @rf_num_weeks.to_i  * @rf_default.to_i
              @rf_amt_past_due      = (@rf_account.to_i - @rf_insured_amount.to_i) * -1
              @rf_num_weeks_past_due  = (@rf_amt_past_due.to_i / @rf_default.to_i)

              if @rf_account.to_i > @rf_insured_amount.to_i
                @rf_status = "advanced"
              elsif @rf_account.to_i < @rf_insured_amount.to_i
                @rf_status  = "past due"
              else
                @rf_status = "normal"
              end

              #compute LIF
              @lif_default = 15
              @lif_account = ReadOnlyMemberAccount.where(account_subtype: "Life Insurance Fund", member_id: member.id).sum(:balance)
              @lif_coverage = (recognition_date.to_date + (@lif_account.to_i / @lif_default.to_i).weeks).strftime("%Y-%m-%d")
              @lif_num_days   = current_date.to_date - recognition_date.to_date
              @lif_num_weeks  = (@lif_num_days.to_i / 7) + 1
              @lif_insured_amount    = @lif_num_weeks.to_i  * @lif_default.to_i
              @lif_amt_past_due      = (@lif_account.to_i - @lif_insured_amount.to_i) * -1
              @lif_num_weeks_past_due  = (@lif_amt_past_due.to_i / @lif_default.to_i)

              if @lif_account.to_i > @lif_insured_amount.to_i
                @lif_status = "advanced"
              elsif @lif_account.to_i < @lif_insured_amount.to_i
                @lif_status  = "past due"
              else
                @lif_status = "normal"
              end

              member_record[:index]                  = i+1
              member_record[:name]                   = member.full_name_titleize
              member_record[:mobile_number]          = member.mobile_number
              member_record[:recognition_date]       = member.data['recognition_date']
              member_record[:status]                 = member.status
              member_record[:insurance_status]       = member.insurance_status
              member_record[:length_of_stay_report]  = member.length_of_stay_reports
              member_record[:identification_number]  = member.identification_number
              member_record[:rf_account]             = @rf_account
              member_record[:rf_coverage]            = @rf_coverage
              member_record[:rf_num_weeks_past_due]  = @rf_num_weeks_past_due
              member_record[:rf_amt_past_due]        = @rf_amt_past_due
              member_record[:rf_status]              = @rf_status
              member_record[:lif_account]            = @lif_account
              member_record[:lif_coverage]           = @lif_coverage
              member_record[:lif_num_weeks_past_due] = @lif_num_weeks_past_due
              member_record[:lif_amt_past_due]       = @lif_amt_past_due
              member_record[:lif_status]             = @lif_status
              member_center[:members] << member_record
            end
          end

          @data[:centers] << member_center
        end
      end

      @data
    end
  end
end
