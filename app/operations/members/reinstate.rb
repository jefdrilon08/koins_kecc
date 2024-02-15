module Members
  class Reinstate
    def initialize(member:, reinstatement_date:, reinstate_by:, date_stop:)
      @member              = member
      @recognition_date    = @member.recognition_date
      @reinstatement_date  = reinstatement_date
      @date_stop           = date_stop
      @reinstate_by        = reinstate_by
      @member_data         = @member.data.with_indifferent_access
    
      @member_data[:reinstatement] = {}
    end

    def execute!
      @member_data[:recognition_date] = @reinstatement_date
      @member_data[:reinstatement][:reinstatement_date] = @reinstatement_date
      @member_data[:reinstatement][:date_stop] = @date_stop
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