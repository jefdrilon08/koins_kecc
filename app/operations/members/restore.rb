module Members
  class Restore
    def initialize(config:)
      @config = config
      @member = @config[:member]
      @user   = @config[:user]
  
      # Reference member's data object
      @data = @member.data.with_indifferent_access

      @current_date = Date.today
    end

    def execute!
      # Reset loan cycle
      @data[:loan_cycles] = nil

      # Reset entry_point_loan_cycle
      @data[:entry_point_loan_cycle] = 0

      # Load/archive resignation records
      resignation_records = @member.resignation_records

      resignation_records << @member.resignation

      @data[:resignation_records] = resignation_records

      # Reset resignation
      @data[:resignation] = {
        type: "",
        code: "",
        reason: "",
        accounting_reference_number: ""
      }

      # Restoration records
      restoration_records = @data[:restoration_records] || []

      restoration_records << {
        date_restored: @current_date,
        user: {
          id: @user.id,
          first_name: @user.first_name,
          last_name: @user.last_name,
          identification_number: @user.identification_number
        }
      }

      # Void all memberhsip_payment_records
      MembershipPaymentRecord.where(member_id: @member.id).each do |mpr|
        mpr.update!(
          status: "void",
          date_voided: @current_date
        )
      end

      # Void previous validation if any
      member_account_validation_record = MemberAccountValidationRecord.where("member_id = ? AND data ->> 'is_void' = ?", @member.id, 'false').order("created_at ASC").last
      if !member_account_validation_record.nil?
        member_account_validation_record_data = member_account_validation_record.data.with_indifferent_access
        member_account_validation_record_data[:is_void] = true
        member_account_validation_record.update!(data: member_account_validation_record_data)
      end

      @data[:restoration_records] = restoration_records
      @data[:recognition_date] = nil

      # Update member
      previous_date_resigned  = @member.date_resigned
      @member.update!(
        status: "pending",
        insurance_status: "pending",
        date_resigned: nil,
        insurance_date_resigned: nil,
        previous_date_resigned: previous_date_resigned,
        data: @data
      )

      @member
    end
  end
end
