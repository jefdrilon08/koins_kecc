module Api
  module V3
    class MembersController < ::Api::V3::ApplicationController
      before_action :authenticate_user!, except: [
        :login, 
        :dashboard, 
        :savings,
        :verify_code,
        :member_change_password
      ]

      before_action :authorize_mis!, except: [
        :login, 
        :dashboard, 
        :savings,
        :verify_code,
        :member_change_password
      ]

      before_action :authenticate_member!, only: [
        :dashboard, 
        :savings
      ]

      before_action :authorize_active_member!, only: [
        :dashboard, 
        :savings
      ]

      def dashboard
        cmd = ::Members::GetDashboard.new(
          member: @current_member
        )

        cmd.execute!

        render json: cmd.payload
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

          mobile_number = cmd.member.mobile_number
          member["mobile_number"] = mobile_number.gsub(/[&\/\\#,\-\_()$~%.'":*?<>{}]/, '') # remove all the special characters
          # render json: { token: cmd.token, member: cmd.member.user_object }
          # render json: { token: cmd.token, member: member }
          
          if(cmd.member_logged_before) # if this member logged before in koins mobile
            render json: { token: cmd.token, member: member, member_logged_before: cmd.member_logged_before }
          else # if not
            render json: { member: member, member_logged_before: cmd.member_logged_before, memberPasswordChanged: cmd.member_password_changed }
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

          render json: { token: cmd.token, member: member }
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
          member_data["password_changed"] = true # set to true
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
    end
  end
end
