module Api
  class MembersController < ::Api::FrontController
    before_action :authenticate_member!, except: [:login, :apply_online, :index, :unlock, :update_password, :create_survey, :balik_kasapi, :delete]
    before_action :authenticate_user!, only: [:save, :index, :unlock, :update_password, :create_survey, :balik_kasapi]

    def save
      member_data = JSON.parse(params[:member_data]).to_h.with_indifferent_access

      config  = {
        member_data: member_data,
        user: current_user
      }

      errors = ::Members::ValidateSave.new(
        config: config
      ).execute!

      if errors[:full_messages].any?
        render json: errors, status: 400
      else
        member  = ::Members::Save.new(
                    config: config
                  ).execute!

        ActivityLog.create!(
          content: "#{current_user.full_name} modified member #{member.full_name}",
          activity_type: "modification",
          data: {
            user_id: current_user.id,
            member_id: member.id,
            member_data: member_data
          }
        )

        render json: { id: member.id }
      end
    end

    def create_survey
      member  = Member.find(params[:id])
      survey  = Survey.find_by_id(params[:survey_id])

      config = {
        member: member,
        survey: survey,
        user:   @user
      }

      errors = ::Members::ValidateCreateSurvey.new(
        config: config
      ).execute!

      if errors[:messages].any?
        render json: errors, status: :unprocessable_entity
      else
        survey_answer = ::Members::BuildSurveyAnswer.new(
          config: config
        ).execute!

        survey_answer.save!

        render json: { id: survey_answer.id }
      end
    end

    def balik_kasapi
      member = Member.find(params[:id])
      
      config = {
        user: @user,
        member: member
      }

      errors  = ::Members::ValidateRestore.new(
                  config: config
                ).execute!
      
    
      if errors[:messages].any?

        render json: errors, status: 400
      else
        
        ::Members::Restore.new(
          config: config
        ).execute!

        render json: { id: member.id,  message: "ok"  }


      end
    
    end

      def delete
        member  = Member.find(params[:id])
        config  = {
          member: member,
          user: current_user
        }

        errors  = ::Members::ValidateDelete.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          member_id         = member.id
          member_full_name  = member.full_name

          ::Members::Delete.new(
            config: config
          ).execute!

          ActivityLog.create!(
            content: "#{current_user.full_name} deleted member #{member_full_name}",
            activity_type: "deletion",
            data: {
              user_id: current_user.id,
              member_id: member_id
            }
          )

          render json: { message: "ok" }
        end
      end


    def unlock

        
      member = Member.find(params[:id])
      
      config = {
        member: member,
        user:   @user
      }

      cmd = ::Members::ValidateUnlock.new(
        config: config
      )

      cmd.execute!

      if cmd.messages.any?
        render json: { errors: cmd.messages }, status: :unprocessable_entity
      else
        member.update!(modifiable: true)

        render json: { message: "ok", id: member.id }
      end
    end

    def index
      branches = ReadOnlyBranch.select(
        "branches.id, branches.name"
      ).where(
        id: ReadOnlyUserBranch.where(
              active: true,
              user_id: @user.id
            ).pluck(:branch_id)
      ).order(
        "name ASC"
      )

      q = params[:q]

      members = Member.joins(
        :branch
      ).select(
        "members.id, members.first_name, members.middle_name, members.last_name, branches.name AS branch_name, status"
      ).where(
        "branches.id IN (?) AND status = ?",
        branches.pluck(:id),
        "active"
      ).where(
        "upper(first_name) LIKE :q OR upper(last_name) LIKE :q OR upper(identification_number) LIKE :q",
        q: "%#{q.upcase}%"
      ).order(
        "members.last_name ASC"
      ).limit(50)

      render json: { members: members }
    end

    def update_password
      password              = params[:password]
      password_confirmation = params[:password_confirmation]
      member                = Member.find_by_id(params[:id])

      cmd = ::Members::ValidateUpdatePassword.new(
        member:                 member,
        password:               password,
        password_confirmation:  password_confirmation,
        user:                   @user
      )

      cmd.execute!

      if cmd.messages.any?
        render json: { errors: cmd.messages }, status: :unprocessable_entity
      else
        member.update!(
          password: password,
          password_confirmation: password_confirmation
        )

        render json: { message: "ok" }
      end
    end

    def change_password
      old_password          = params[:old_password]
      password              = params[:password]
      password_confirmation = params[:password_confirmation]

      cmd = ::Members::ValidateChangePassword.new(
              member: @member,
              old_password: old_password,
              password: password,
              password_confirmation: password_confirmation
            )

      cmd.execute!

      if not cmd.errors.blank?
        render json: { errors: cmd.errors }, status: :unprocessable_entity
      else
        @member.update!(
          password: password,
          password_confirmation: password_confirmation
        )

        render json: { message: "ok" }
      end
    end

    def apply_online
      payload = JSON.parse(params[:payload]).with_indifferent_access

      validator = ::Members::ValidateApplyOnline.new(
                    first_name:       payload[:first_name],
                    middle_name:      payload[:middle_name],
                    last_name:        payload[:last_name],
                    gender:           payload[:gender],
                    date_of_birth:    payload[:date_of_birth],
                    email:            payload[:email],
                    mobile_number:    payload[:mobile_number],
                    address_region:   payload[:address_region],
                    address_province: payload[:address_province],
                    address_district: payload[:address_district],
                    address_street:   payload[:address_street],
                    address_city:     payload[:address_city],
                    file_document:    params[:file_document],
                    profile_picture:  params[:profile_picture],
                    agree_to_terms:   payload[:agree_to_terms]
                  )

      validator.execute!

      if validator.num_errors > 0
        render json: { errors: validator.errors }, status: :unprocessable_entity
      else
        cmd = ::Members::ApplyOnline.new(
                first_name:       payload[:first_name],
                middle_name:      payload[:middle_name],
                last_name:        payload[:last_name],
                gender:           payload[:gender],
                date_of_birth:    payload[:date_of_birth],
                email:            payload[:email],
                mobile_number:    payload[:mobile_number],
                address_region:   payload[:address_region],
                address_province: payload[:address_province],
                address_district: payload[:address_district],
                address_street:   payload[:address_street],
                address_city:     payload[:address_city],
                file_document:    params[:file_document],
                profile_picture:  params[:profile_picture],
                agree_to_terms:   payload[:agree_to_terms]
              )

        cmd.execute!

        render json: { reference_number: cmd.reference_number }
      end
    end

    def login
      username  = params[:username]
      password  = params[:password]

      cmd = ::Members::ValidateLogin.new(
              username: username,
              password: password
            )

      cmd.execute!

      if cmd.errors.any?
        render json: { errors: cmd.errors }, status: :unprocessable_entity
      else
        render json: { token: cmd.token, member: cmd.member.user_object }
      end
    end

    def total_funds
      amount = @member.member_accounts.savings.sum(:balance).to_f

      render json: { amount: amount }
    end

    def total_active_loan_balance
      amount = @member.loans.active.sum("principal_balance + interest_balance").to_f

      render json: { amount: amount }
    end

    def insurance_fund
      amount = @member.member_accounts.insurance.sum(:balance).to_f

      render json: { amount: amount }
    end

    def total_equities
      amount = @member.member_accounts.equities.sum(:balance).to_f

      render json: { amount: amount }
    end

    def active_loans
      cmd = ::Members::GetLoans.new(
              member: @member
            )

      cmd.execute!

      render json: cmd.data
    end
  end
end
