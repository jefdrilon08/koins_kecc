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
      @data[:loan_cycles] = []

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

      @data[:restoration_records] = restoration_records

      # Update member
      @member.update!(
        status: "pending",
        insurance_status: "pending",
        date_resigned: nil,
        data: @data
      )

      @member
    end
  end
end
