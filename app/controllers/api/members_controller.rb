module Api
  class MembersController < ::Api::FrontController
    before_action :authenticate_member!, except: [
      :login,
      :apply_online,
      :index,
      :unlock,
      :update_password,
      :create_survey,
      :claims_copy_pdf,
      :balik_kasapi,
      :reinstate,
      :delete,
      :form_make_payments,
      :add_recognition_date,
      :update_recognition_date,
      :is_member_subscribed,
      :update_member_subscription
    ]

    before_action :authenticate_user!, only: [
      :save,
      :index,
      :unlock,
      :update_password,
      :create_survey,
      :balik_kasapi,
      :claims_copy_pdf,
      :reinstate,
      :form_make_payments,
      :add_recognition_date,
      :update_recognition_date,
      :is_member_subscribed,
      :update_member_subscription
    ]

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

    def reinstate
      member = Member.find(params[:id])
      reinstatement_date = params[:reinstatement_date]
      date_stop = params[:date_stop]

      begin
        # Validate reinstatement and get last transaction date
        errors = ::Members::ValidateReinstatement.new(
          member: member,
          reinstatement_date: reinstatement_date,
          date_stop: date_stop
        ).execute!

        last_account_transaction_date = ::Members::ValidateLastAccountTransactionDate.new(
          member: member,
          reinstatement_date: reinstatement_date,
          date_stop: date_stop
        ).execute!

        if errors.empty?
          # Proceed with reinstatement
          ::Members::Reinstate.new(
            member: member,
            reinstatement_date: reinstatement_date,
            date_stop: date_stop,
            reinstate_by: current_user.full_name
          ).execute!

          render json: { id: member.id }
        else
          render json: { errors: errors }, status: :unprocessable_entity
        end
      rescue => e
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end
    end


    def add_recognition_date
      member            = Member.find(params[:id])
      recognition_date  = params[:recognition_date]
      status            = 'active'
      config  = {
        member: member,
        user: current_user.full_name,
        recognition_date: recognition_date

      }

      errors = ::Members::ValidateRecognitionDate.new(
        member: member,
        recognition_date: recognition_date
      ).execute!

      if errors.any?
        render json: { errors: [errors] }, status: :unprocessable_entity
      else
        data  = member.data.with_indifferent_access

          data[:recognition_date] = recognition_date
          if member.identification_number.present?
            identification_number = member.identification_number
          else
            identification_number = ::Members::GenerateMemberIdentificationNumber.new(
                                              member: member
                                              ).execute!
            c = member.branch.try(:member_counter) || 0
            member.branch.update(member_counter: c + 1)
          end
          member.update!(
            data: data,
            identification_number: identification_number,
            modifiable: nil
          )
        ::Members::UpdateRecognitionDate.new(
          member: member,
          recognition_date: recognition_date,
          status: status
        ).execute!
        render json: { id: member.id }
      end
    end

    def update_recognition_date
      member                       = Member.find(params[:id])
      previous_recognition_date    = params[:previous_recognition_date]
      update_recognition_date      = params[:update_recognition_date]
      user                         = current_user

      errors = ::Members::ValidateUpdateRecognitionDate.new(
        member: member,
        previous_recognition_date: previous_recognition_date,
        update_recognition_date: update_recognition_date,
        user: user
      ).execute!

      if errors.any?
        render json: { errors: [errors] }, status: :unprocessable_entity
      else
        member.update!(modifiable: nil)
        ::Members::UpdateNewRecognitionDate.new(
          member: member,
          previous_recognition_date: previous_recognition_date,
          update_recognition_date: update_recognition_date,
          user: user,
        ).execute!
        render json: { id: member.id }
      end
    end

    def claims_copy_pdf
      @member             = Member.find(params[:id])
      @date_of_death      = params[:date_of_death]

      session[:date_of_death] = @date_of_death
    end

    def resign
        member = Member.find(params[:id])
        date_resigned = params[:date_resigned]
        reason        = params[:reason]
        errors        = ::Members::ValidateResign.new(
                          member: member,
                          date_resigned: date_resigned
                        ).execute!

        if errors.size == 0
          ::Members::Resign.new(
            member: member,
            date_resigned: date_resigned,
            reason: reason,
            resigned_by: current_user.full_name
          ).execute!

          render json: { id: member.id }
        else
          render json: { errors: errors }, status: 402
        end
      end

    def is_reclassified
      member               = Member.find(params[:id])
      is_reclassified      = params[:is_reclassified]
      config  = {
        member: member,
        user: current_user,
        is_reclassified: is_reclassified
      }
      errors = ::Members::ValidateReclassified.new(
        member: member,
        is_reclassified: is_reclassified
      ).execute!

      if errors.any?
        render json: errors, status: 400
      else
        ::Members::ReclassifiedMember.new(
          member: member,
          is_reclassified: is_reclassified
        ).execute!
      end
    end

    def form_make_payments

    @member = Member.find(params[:id])
    config = {
                member_id: @member.id,
                make_payment_type: params[:type]

              }
    @data = ::Members::BuildMakePayments.new(config: config).execute!

    @accounting_entry = ::Members::BuildAccountingEntryForMakePayments.new(
                                    make_payment_data: @data,
                                    current_user: current_user,
                                    make_payment_type: params[:type]

                                    ).execute!

    @subheader_items = [
      { is_link: true, path: members_path, text: "Members" },
      { is_link: true, path: member_path(@member), text: "#{@member.full_name}" },
      { text: "Make Payment Form" }
    ]


    @subheader_side_actions = [
      {
        id: "btn-save",
        link: "#",
        class: "fa fa-check",
        text: "Save",

        data: { member_id: @member.id, make_payment_type: params[:type] }
      },
      {
        is_link: true,
        path: member_path(@member),
        class: "fa fa-times",
        text: "Cancel" }
    ]
    # @payload = {
    #   id: @member.id,
    #   memberResignationTypes: helpers.member_resignation_types
    # }
  end

    def balik_kasapi
      member = Member.find(params[:id])
      member_share = member.member_shares

      if member_share.present?
        member_share.each do |member_share| 
          if member_share.is_void
            member_share.update(certificate_for: "VOID")
          else
            member_share.update(is_void: true, certificate_for: "VOID")
          end

          unless member_share.save
            Rails.logger.error "Failed to save updated member_share #{member_share.id}: #{member_share.errors.full_messages.join(', ')}"
          end
        end
      else
        Rails.logger.error "No member_share found for member #{member.id}"
      end

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
      ).page(params[:page]).per(
        LIST_PAGE_SIZE
      )

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

    def is_member_subscribed
      member = Member.find(params[:id])

      config = {
        member: member,
        user:   @user
      }

      cmd = ::Members::ValidateMemberSubscription.new(
        config: config
      )

      cmd.execute!

      if cmd.messages.any?
        render json: { errors: cmd.messages }, status: :unprocessable_entity
      else
        member_data = member.data.with_indifferent_access

        if !member_data.key?(:subscription)
          member_data["subscription"] = {}
          member_data["subscription"]["is_subscribed"] = false
          member_data["subscription"]["subscribe_created_at"] = Time.now
          member_data["subscription"]["subscribe_updated_at"] = Time.now
          member.update(data: member_data)
        end

        render json: { message: "ok", is_subscribed: member_data["subscription"]["is_subscribed"] }
      end
    end

    def update_member_subscription
      member = Member.find(params[:id])

      config = {
        member: member,
        user:   @user
      }

      cmd = ::Members::ValidateUpdateMemberSubscription.new(
        config: config
      )

      cmd.execute!

      puts "cmd.messagescmd.messages: " + cmd.messages.inspect
      if cmd.messages.any?
        render json: { errors: cmd.messages }, status: :unprocessable_entity
      else
        member_data = member.data.with_indifferent_access

        member_data["subscription"]["is_subscribed"] = !member_data["subscription"]["is_subscribed"]
        member_data["subscription"]["subscribe_updated_at"] = Time.now

        member.update(data: member_data)

        render json: { message: "ok", is_subscribed: member_data["subscription"]["is_subscribed"] }
      end
    end
  end
end
