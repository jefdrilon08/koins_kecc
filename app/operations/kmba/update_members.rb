module Kmba
  class UpdateMembers

    def initialize(config:)
      super()
      @config = config
    end

    def execute!
      @config.map{ |a|
        member = Member.new(
          center_id: a[:center_id],
          branch_id: a[:branch_id],
          first_name: a[:first_name],
          middle_name: a[:middle_name],
          last_name: a[:last_name],
          gender: a[:gender],
          date_of_birth: a[:date_of_birth],
          civil_status: a[:civil_status],
          home_number: a[:home_number],
          mobile_number: a[:mobile_number],
          processed_by: a[:processed_by],
          approved_by: a[:approved_by],
          identification_number: a[:identification_number],
          place_of_birth: a[:place_of_birth],
          status: a[:status],
          member_type: a[:member_type],
          religion: a[:religon],
          insurance_status: a[:insustatus],  
          data: a[:data],
          access_token: a[:access_token],
          signature_data: a[:signature_data],
          modifiable: a[:modifiable],
          previous_date_resigned: a[:previous_date_resigned],
          insurance_date_resigned: a[:insurance_date_resigned],
          member_id: a[:member_id],
          encrypted_password: a[:encrypted_password],
          username: a[:username],
          online_application_id: a[:online_application_id],
          membership_arrangement_id: a[:membership_arrangement_id],
          membership_type_id: a[:membership_type_id],
          referrer_id: a[:referrer_id],
          coordinator_id: a[:coordinator_id],
          email: a[:email]
        )

        Rails.logger.info(puts " New Record is Save ID NO : #{a[:identification_number]}, saved! ")
        member.save!
      }
    end
  end
end