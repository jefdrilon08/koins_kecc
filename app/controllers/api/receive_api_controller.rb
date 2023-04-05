  module Api
    class ReceiveApiController < ActionController::API
      def save_members_api
        
        @members = []
        @config = {}

      # raise params[:_json].inspect      
      members = params[:_json]

      # raise member_data.inspect
      members.each do |m|
        @member_data  = {}
        @member_data[:center_id]                    = m["center_id"]
        @member_data[:branch_id]                    = m["branch_id"]
        @member_data[:first_name]                   = m["first_name"]
        @member_data[:middle_name]                  = m["middle_name"]
        @member_data[:last_name]                    = m["last_name"]
        @member_data[:gender]                       = m["gender"]
        @member_data[:date_of_birth]                = m["date_of_birth"]
        @member_data[:status]                       = m["status"]
        @member_data[:member_type]                  = m["member_type"]
        @member_data[:religion]                     = m["religion"]
        @member_data[:insurance_status]             = m["insurance_status"]
        @member_data[:data]                         = m["data"]
        @member_data[:date_resigned]                = m["date_resigned"]
        @member_data[:meta]                         = m["meta"]
        @member_data[:created_at]                   = m["created_at"]
        @member_data[:updated_at]                   = m["updated_at"]
        @member_data[:access_token]                 = m["access_token"]
        @member_data[:signature_data]               = m["signature_data"]
        @member_data[:modifiable]                   = m["modifiable"]
        @member_data[:previous_date_resigned]       = m["previous_date_resigned"]
        @member_data[:insurance_date_resigned]      = m["insurance_date_resigned"]
        @member_data[:member_id]                    = m["member_id"]
        @member_data[:encrypted_password]           = m["encrypted_password"]
        @member_data[:username]                     = m["username"]
        @member_data[:online_application_id]        = m["online_application_id"]
        @member_data[:membership_type_id]           = m["membership_type_id"]
        @member_data[:referrer_id]                  = m["referrer_id"]
        @member_data[:coordinator_id]               = m["coordinator_id"]
        @member_data[:email]                        = m["email"]

        # raise @member_data.inspect
        @members << @member_data        
      end 

      @config = @members.map{ |o|
        {
          center_id: o[:center_id],
          branch_id: o[:branch_id],
          first_name: o[:first_name],
          middle_name: o[:middle_name],
          last_name: o[:last_name],
          gender: o[:gender],
          date_of_birth: o[:date_of_birth],
          status: o[:status],
          member_type: o[:member_type],
          religion: o[:religion],
          insurance_status: o[:insurance_status],
          data: o[:data],
          date_resigned: o[:date_resigned],
          meta: o[:meta],
          created_at: o[:created_at],
          updated_at: o[:update_at],
          access_token: o[:access_token],
          signature_data: o[:signature_data],
          modifiable: o[:modifiable],
          previous_date_resigned: o[:previous_date_resigned],
          insurance_date_resigned: o[:insurance_date_resigned],
          member_id: o[:member_id],
          encrypted_password: o[:encrypted_password],
          username: o[:username],
          online_application_id: o[:online_application_id],
          membership_type_id: o[:membership_type_id],
          referrer_id: o[:referrer_id],
          coordinator_id: o[:coordinator_id],
          email: o[:email]
        }
      }.to_s


      raise @config.inspect
      # errors = ::Kmba::ValidateSaveMembers.new(
      #       config: @config
      #   ).execute!


      # raise @member.inspect
      

      # raise member_data.inspect
      # num = 1 
        # member_data.each do |key, value|
        #   puts "#{key} : #{value}"
        #   num += 1  
        # end

      # member_data = []
      # member_data = {
      #   center_id: center_id,
      #     branch_id: branch_id,
      #     first_name: first_name,
      #     middle_name: middle_name,
      #     last_name: last_name,
      #     gender: gender,
      #     date_of_birth: date_of_birth,
      #     civil_status: civil_status,
      #     home_number: home_number,
      #     mobile_number: mobile_number,
      #     processed_by: processed_by,
      #     approved_by: approved_by,
      #     identification_number: identification_number,
      #     place_of_birth: place_of_birth,
      #     status: status,
      #     member_type: member_type,
      #     religion: religion,
      #     insurance_status: insurance_status,
      #     data: data,
      #     date_resigned: date_resigned,
      #     meta: meta,
      #     created_at: created_at,
      #     updated_at: updated_at,
      #     access_token: access_token,
      #     signature_data: signature_data,
      #     modifiable: modifiable,
      #     previous_date_resigned: previous_date_resigned,
      #     insurance_date_resigned: insurance_date_resigned,
      #     member_id: member_id,
      #     encrypted_password: encrypted_password,
      #     username: username,
      #     online_application_id: online_application_id,
      #     membership_arrangement_id: membership_arrangement_id,
      #     membership_type_id: membership_type_id,
      #     referrer_id: referrer_id,
      #     coordinator_id: coordinator_id,
      #     email: email
      # }

      # # raise member_data.inspect
      # member_data.new(){|i|
      #   i.to_s

      # }

      # raise member_data.inspect
        # raise member_data.select{ |x| 
        #   x["center_id"] == "ff72b4e8-947f-46dd-9bce-ba34497cacdf"
        # }.inspect
      


          # if errors[:full_messages].any?
          #   render json: errors, status: 400
          # # elsif Member.where(:identification_number => config[:identification_number]).count >= 1
        # #     cmd = ::Kmba::UpdateMembers.new(
        # #       config: config
        # #     ).execute! 
          # # # elsif Member.where(:identification_number => config[:identification_number]).any?
        # # #     cmd = ::Kmba::UpdateMembers.new(
        # # #       config: config
        # # #     ).execute! 
        # # elsif Member.where(:identification_number => config[:identification_number]).nil?
          # #   puts "error id is nil"
          # # else
        # #     # render json: { message: "ok" }
        # #     cmd = ::Kmba::SaveMembers.new(
        # #       config: config
        # #     ).execute!
          # end
      end
    end
end
