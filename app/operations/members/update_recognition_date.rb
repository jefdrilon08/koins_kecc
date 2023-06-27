module Members
  class UpdateRecognitionDate
    def initialize(member:, recognition_date:, change_by:)
      @member              = member
      @recognition_date    = recognition_date
      @change_by           = change_by
      @member_data         = @member.data.with_indifferent_access

    
      @member_data[:recognition_date]
    end

    def execute!
      @member_data[:recognition_date] = @recognition_date
      @member_data[:change_by] = @change_by
      @member.update!(data: @member_data)


      membership_payment = @member.membership_payment_records.where(membership_type: "Insurance", membership_name: "K-MBA").order("date_paid ASC").last

      if membership_payment.present?
        if member.pending? && member.insurance_pending?
            status = "active"
            insurance_status = "inforce"
            membership_payment.update!(date_paid: @recognition_date)
            status.update!(status: status)
            insurance_status.update!(insurance_status: insurance_status)
          else
            status = member.status
            insurance_status = member.status
          end


        # ::Members::GenerateMemberIdentificationNumber.new(
        #   member: @member
        # ).execute!

      end
    end
  end
end