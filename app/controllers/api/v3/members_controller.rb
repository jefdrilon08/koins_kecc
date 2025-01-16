module Api
  module V3
    class MembersController < ::Api::V3::ApplicationController
      before_action :authenticate_user!, except: [
        :login,
        :passing_otp_code,
        :dashboard, 
        :savings,
        :verify_code,
        :member_change_password,
        :project_types,
        :confirmation_changepass,
        :member_change_old_password
      ]

      
      before_action :authorize_mis!, except: [
        :login,
        :passing_otp_code,
        :dashboard, 
        :savings,
        :verify_code,
        :member_change_password,
        :project_types,

        :confirmation_changepass,
        :member_change_old_password
      ]

      before_action :authenticate_member!, only: [
        :dashboard, 
        :savings,
        :member_change_old_password
      ]

      before_action :authorize_active_member!, only: [
        :dashboard, 
        :savings,
        :member_change_old_password
      ]

    

      def dashboard
        member_data = allowed_member_attributes(member) 
        member = @current_member
        cmd = ::Members::GetDashboard.new(
          member: member
        )

        cmd.execute!

        render json: { 
    dashboard: cmd.payload, 
    member: member_data 
  }
      end
      def authenticate_member!
        @current_member = Member.find_by(id: session[:member_id]) # or from token, etc.
      
        unless @current_member
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end
      
      def allowed_member_attributes(member)
        # Define which fields you want to include
        allowed_fields = [:id, :first_name, :last_name, :mobile_number,
         :member_type, :identification_number, :branch_id, :center_id, :membership_arrangement_id]
        
        #  getting the member type
        # Get the branch name if branch_id is present
        branch_name = member.branch&.name
        center_name = member.center&.name
        membership_arrangement_name = member.membership_arrangement&.name
        # Filter the member attributes based on the allowed fields
        attributes = member.attributes.slice(*allowed_fields.map(&:to_s)).with_indifferent_access
        
        # Add the branch and center names if their IDs are present
        attributes[:branch_name] = branch_name if attributes[:branch_id].present?
        attributes[:center_name] = center_name if attributes[:center_id].present?
        attributes[:membership_arrangement_name] = membership_arrangement_name if attributes[:membership_arrangement_id].present?
        # Add the is_otp_code field from data if it exists
        attributes[:is_otp_code] = member.data['is_otp_code'] if member.data&.key?('is_otp_code')
        attributes.except!(:membership_arrangement_id)
        attributes
      end  
      
      def member_type
        # Find the member by ID
        member = Member.find_by(id: params[:id])
        
        # Handle the case where the member is not found
        if member.nil?
          render json: { error: 'Member not found' }, status: :not_found
          return
        end
      
        # Get allowed member attributes
        member_data = allowed_member_attributes(member)
        
        # Render the member data in the response
        render json: { member: member_data }
      end


      def passing_otp_code
        # Find the member by ID
        member = Member.find_by(id: params[:id])

        if member.nil?
          render json: { error: 'Member not found' }, status: :not_found
          return
        end
      
        # Get allowed member attributes
        member_data = allowed_member_attributes(member)
        
        # Render the member data in the response
        render json: { member: member_data }
      end



      
      def login
        username  = params[:username]
        password  = params[:password]
      
        cmd = ::Members::ValidateLogin.new(
          username: username,
          password: password
        )
      
        cmd.execute!
      
        if cmd.invalid?
          render json: cmd.errors, status: :unprocessable_entity
        else
          member = cmd.member.user_object.with_indifferent_access
      
          # Clean the mobile number
          mobile_number = cmd.member.mobile_number
          member["mobile_number"] = mobile_number.gsub(/[&\/\\#,\-\_()$~%.'":*?<>{}]/, '') # remove all special characters
          
          # Add all allowed member attributes
          member_data = allowed_member_attributes(cmd.member)
          # member_data = passing_otp_code(cmd.member)
          if cmd.token # if this member has a token
            current_member = Member.find(cmd.member.id)
            current_member_data = current_member.data.with_indifferent_access
      
            if !current_member_data.key?(:koinsmobile_first_login_date)
              current_member_data["koinsmobile_first_login_date"] = Time.now
              current_member.update(data: current_member_data)
            end
      
            render json: { token: cmd.token, member: member_data }
          else # if not
            render json: { member: member_data, is_otp_verified: cmd.is_otp_verified, is_password_changed: cmd.is_password_changed }
          end
        end
      end

      

      
      
      def import_members
        validator = ::Core::Members::ValidateImportMembers.new(
          data: params[:data]
        )

        validator.execute!

        if validator.valid?
          render json: { message: 'ok' }
        else
          render json: validator.payload, status: :unprocessable_entity
        end
      end





      def verify_code
        username  = params[:username]
        password  = params[:password]
        code = params[:code]
        
        cmd = ::Members::ValidateSmsCode.new(
          username: username,
          password: password,
          code: code
        )

        cmd.execute!
        
        if cmd.invalid?
          render json: cmd.errors, status: :unprocessable_entity
        else
          member = cmd.member.user_object.with_indifferent_access

          mobile_number = cmd.member.mobile_number
          member["mobile_number"] = mobile_number.gsub(/[&\/\\#,\-\_()$~%.'":*?<>{}]/, '') # remove all the special characters

          render json: { member: member }
        end
      end

      def member_change_password
        password              = params[:password]
        password_confirmation = params[:password_confirmation]
        member                = Member.find_by_id(params[:id])

        cmd = ::Members::ValidatePasswordChange.new(
          member:                 member,
          password:               password,
          password_confirmation:  password_confirmation,
        )

        cmd.execute!

        if cmd.messages.any?
          render json: { errors: cmd.messages }, status: :unprocessable_entity
        else
          member_data = member.data.with_indifferent_access
          member_data["is_password_changed"] = true # set to true
          member_data["password_changed_date"] = Time.now # save the date changed
          member.update(data: member_data) # update data

          # update password changed
          member.update!( 
            password: password,
            password_confirmation: password_confirmation
          )

          render json: { message: "ok" }
        end
      end

      def project_types
        project_type_category = JSON.parse(ReadOnlyProjectTypeCategory.where(is_active: true).select('id','name').to_json)
        
        project_type_category.each_with_index do |category, catergory_index|
          project_types = JSON.parse(ProjectType.where(project_type_category_id: category["id"],is_active: true).select('id','name').to_json)
          project_type_category[catergory_index]["project_types"] = project_types
          
        end

        render json: { project_types: project_type_category }
      end

      def confirmation_changepass

        username            = params[:username]
        mobile_number       = params[:mobile_number].gsub(/[&\/\\#,\-\_()$~%.'":*?<>{}]/, '') # remove all the special characters
      
        checkingmember      = Member.where(username: username).where("mobile_number LIKE ?", "%"+ mobile_number).where(status: "active").count

        if checkingmember >= 1
          member_data = {}
          member = Member.find_by_username(username)

          if member.data["is_password_changed"]
            member_data["id"] = member.id
            member_data["first_name"] = member.first_name
            member_data["mobile_number"] = member.mobile_number
            render json: { message: "ok", data:member_data }

          else
            render json: { message: "This can\'t be process" }
          end
          
        else
          render json: { message: "not found" }
        end

      end

      def member_change_old_password
        # old_password = params[:old_password]
        # new_password = params[:new_password]
        # confirm_new_password = params[:confirm_new_password]
  
          # config = {
          #   member: @current_member,
          #   old_password: old_password,
          #   new_password: new_password,
          #   confirm_new_password: confirm_new_password
          # }
    
        # cmd = ::Members::ValidateMemberChangePassword.new(
        #   config: config
        # )
  
        # cmd.execute!
  
        # if cmd.messages.any?
        #   render json: { errors: cmd.messages }, status: :unprocessable_entity
        # else
        #   @current_member.update!(
        #     password: new_password,
        #     password_confirmation: confirm_new_password
        #   )
  
        #   render json: { message: "ok" }
        # end
        

      end


    end
  end
end
