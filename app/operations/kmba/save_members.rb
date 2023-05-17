module Kmba
  class SaveMembers
     attr_accessor :member

    def initialize(member_data:)
      super()
      @member_data = member_data
    # raise @config.inspect
    end

    def execute!
      # raise @member_data.inspect
        member_data = Member.new(
          center_id: @member_data[:center_id],
          branch_id: @member_data[:branch_id],
          first_name: @member_data[:first_name],
          middle_name: @member_data[:middle_name],
          last_name: @member_data[:last_name],
          gender: @member_data[:gender],
          date_of_birth: @member_data[:date_of_birth],
          civil_status: @member_data[:civil_status],
          home_number: @member_data[:home_number],
          mobile_number: @member_data[:mobile_number],
          processed_by: @member_data[:processed_by],
          approved_by: @member_data[:approved_by],
          identification_number: @member_data[:identification_number],
          place_of_birth: @member_data[:place_of_birth],
          status: @member_data[:status],
          member_type: @member_data[:member_type],
          religion: @member_data[:religion],
          insurance_status: @member_data[:insurance_status],  
          data: @member_data[:data],
          access_token: @member_data[:access_token],
          signature_data: @member_data[:signature_data],
          modifiable: @member_data[:modifiable],
          previous_date_resigned: @member_data[:previous_date_resigned],
          insurance_date_resigned: @member_data[:insurance_date_resigned],
          member_id: @member_data[:member_id],
          encrypted_password: @member_data[:encrypted_password],
          username: @member_data[:username],
          online_application_id: @member_data[:online_application_id],
          membership_arrangement_id: @member_data[:membership_arrangement_id],
          membership_type_id: @member_data[:membership_type_id],
          referrer_id: @member_data[:referrer_id],
          coordinator_id: @member_data[:coordinator_id],
          email: @member_data[:email]
        )

        # raise @member_data.inspect

        Rails.logger.info(puts " New Record is Save ID NO : #{@member_data[:identification_number]}, saved! ", status: 200)
        member_data.save!
    # raise member.inspect
    # @member = Member.find(@member.id)
    end
  end
end
