module Api
  module V1
    class ApiReceiveMembersController < ApiController
      before_action :authenticate_user!

      def approve
        api_receive_member    = ApiReceiveMember.where(id: params[:id]).first
        branch_id             = api_receive_member[:branch_id]
        id                    = api_receive_member.id
        member_data           = api_receive_member.data
        status                = api_receive_member.status

        if ["MIS", "AO"].include? current_user.roles.last
          member_data.each do |m|
            if m['identification_number'].present?
              data = ApiReceiveMembers::UpdateMember.new(
                config: {
                  "insurance_status": m['insurance_status'],
                  "center_id": m['center_id'],
                  "branch_id": branch_id,
                  "identification_number": m['identification_number'],
                  "first_name": m['first_name'],
                  "middle_name": m['middle_name'],
                  "last_name": m['last_name'],
                  "gender": m['gender'],
                  "date_of_birth": m['date_of_birth'],
                  "civil_status": m['civil_status'],
                  "mobile_number": m['mobile_number'],
                  "address_street": m['address_street'],
                  "address_district": m['address_district'],
                  "address_city": m['address_city'],
                  "external_ref": m['external_ref']
                }
              ).execute!
            elsif m['insurance_status'] = "pending"
              data = ApiReceiveMembers::SaveMember.new(
                config: {
                  "insurance_status": m['insurance_status'],
                  "center_id": m['center_id'],
                  "branch_id": branch_id,
                  "identification_number": m['identification_number'],
                  "first_name": m['first_name'],
                  "middle_name": m['middle_name'],
                  "last_name": m['last_name'],
                  "gender": m['gender'],
                  "date_of_birth": m['date_of_birth'],
                  "civil_status": m['civil_status'],
                  "mobile_number": m['mobile_number'],
                  "address_street": m['address_street'],
                  "address_district": m['address_district'],
                  "address_city": m['address_city'],
                  "external_ref": m['external_ref']
                }
              ).execute!
            end
          end

          api_receive_member.update!(status: "approve", date_approve: Date.today)

        else
          errors << "Unauthorized to perform this transaction"
          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end

      def decline
        api_receive_member    = ApiReceiveMember.where(id: params[:id]).first
        # id                    = api_receive_member.id
        # branch_id             = api_receive_member[:branch_id]
        # center_id             = api_receive_member[:center_id]
        # receive_date          = api_receive_member[:receive_date]
        # data                  = api_receive_member.data

        raise api_receive_member.inspect
      end
    end
  end
end
