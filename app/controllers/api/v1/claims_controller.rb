module Api
  module V1
    class ClaimsController < ActionController::Base
      before_action :authenticate_user!

      def create
        member = Member.find(params[:member_id])
        claim_type = params[:claim_type]
        branch = member.branch
        center = member.center

        claim = Claim.new(
                  member: member,
                  branch: branch,
                  center: center,
                  claim_type: claim_type,
                  data: {}
                )

        if claim.save
          render json: { id: claim.id }
        else
          render errors: claim.errors
        end
      end

      # def proceed
      #   claim = Claim.find(params[:id])

      #   config = {
      #     claim: claim,
      #     user: current_user
      #   }

      #   if ["MIS", "AO"].include? current_user.roles.last
      #     errors  = Claims::ValidateClaimForChecking.new(
      #                 config: config
      #               ).execute!

      #     @approving_user = User.where(first_name: "Silvida", last_name: "Antiquera").first

      #     if errors[:messages].any?
      #       render json: { errors: errors }, status: 400
      #     else
      #       claim  = Claims::ProceedClaim.new(
      #                                   config: config
      #                                 ).execute!

      #       ::Claims::NotifyUser.new(claim: claim, user: @approving_user).execute!

      #       render json: { message: "Successfully proceed claim" }
      #     end
      #   else
      #     errors << "Unauthorized to perform this transaction"

      #     render json: { message: "Unauthorized", errors: errors }, status: 401
      #   end
      # end

      def check
        claim = Claim.find(params[:id])

        config = {
          claim: claim,
          user: current_user
        }

        if ["MIS", "AO"].include? current_user.roles.last
          errors  = Claims::ValidateClaimForChecking.new(
                      config: config
                    ).execute!

          @approving_user = User.where(first_name: "Silvida", last_name: "Antiquera").first

          if errors[:messages].any?
            render json: { errors: errors }, status: 400
          else
            claim  = Claims::CheckClaim.new(
                                        config: config
                                      ).execute!

            ::Claims::NotifyUser.new(claim: claim, user: @approving_user).execute!

            render json: { message: "Successfully proceed claim" }
          end
        else
          errors << "Unauthorized to perform this transaction"

          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end

      def declined
        claim = Claim.find(params[:id])
        declined_note   = params[:declined_note]

        config = {
          claim: claim,
          declined_note: declined_note
        }

        if ["MIS", "AO"].include? current_user.roles.last
          errors  = Claims::ValidateClaimForDeclining.new(
                      config: config
                    ).execute!

          first_name = claim.prepared_by.split(" ").first

          @user = User.where(first_name: first_name).first

          if errors[:messages].any?
            render json: { errors: errors }, status: 400
          else
            claim  = Claims::DeclinedClaim.new(
                                        config: config
                                      ).execute!

            ::Claims::NotifyUser.new(claim: claim, user: @user).execute!

            render json: { message: "Successfully proceed claim" }
          end
        else
          errors << "Unauthorized to perform this transaction"

          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end

      def pending
        claim = Claim.find(params[:id])

        config = {
          claim: claim,
          user: current_user
        }

        if ["MIS", "AO"].include? current_user.roles.last
          errors  = Claims::ValidateClaimForPending.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: { errors: errors }, status: 400
          else
            claim  = Claims::PendingClaim.new(
                                        config: config
                                      ).execute!

            render json: { message: "Successfully revert pending claim" }
          end
        else
          errors << "Unauthorized to perform this transaction"

          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end

      def approve
        claim = Claim.find(params[:id])

        config = {
          claim: claim,
          user: current_user
        }

        @posting_user = User.where(first_name: "Evelyn", last_name: "Lagmay").first

        if ["MIS"].include? current_user.roles.last
          errors  = Claims::ValidateClaimForApproval.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: { errors: errors }, status: 400
          else
            claim  = Claims::ApproveClaim.new(
                                        config: config
                                      ).execute!

            ::Claims::NotifyUser.new(claim: claim, user: @posting_user).execute!

            render json: { message: "Successfully approved claim" }
          end
        else
          errors << "Unauthorized to perform this transaction"

          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end

      def save
        claim         = Claim.find(params[:id])
        date_prepared = params[:date_prepared]
        prepared_by   = params[:prepared_by]
        control       = params[:control]
        data          = params[:data]

        errors = []
        if claim.claim_type == "BLIP"
          errors = ::Claims::ValidateBlip.new(claim: claim, data: data, date_prepared: date_prepared, prepared_by: prepared_by, control: control).execute!
        elsif claim.claim_type == "CLIP"
          errors = ::Claims::ValidateClip.new(claim: claim, data: data, date_prepared: date_prepared, prepared_by: prepared_by, control: control).execute!
        elsif claim.claim_type == "HIIP"
          errors = ::Claims::ValidateHiip.new(claim: claim, data: data, date_prepared: date_prepared, prepared_by: prepared_by).execute!
        elsif claim.claim_type == "K-KALINGA"
          errors = ::Claims::ValidateKalinga.new(claim: claim, data: data, date_prepared: date_prepared, prepared_by: prepared_by).execute!
        elsif claim.claim_type == "CALAMITY ASSISTANCE"
          errors = ::Claims::ValidateCalamity.new(claim: claim, data: data, date_prepared: date_prepared, prepared_by: prepared_by).execute!
        elsif claim.claim_type == "K-BENTE"
          errors = ::Claims::ValidateKbente.new(claim: claim, data: data, date_prepared: date_prepared, prepared_by: prepared_by).execute!
        elsif claim.claim_type == "KUYA JUN SCHOLARSHIP PROGRAM"
          errors = ::Claims::ValidateScholarship.new(claim: claim, data: data, date_prepared: date_prepared, prepared_by: prepared_by).execute!
        end

        if errors.size > 0
          render json: { errors: errors }, status: 402
        else
          claim.update!(data: data, date_prepared: date_prepared, prepared_by: prepared_by)
          render json: {message: "ok"}
        end

        branch = Branch.where(id: Settings.try(:defaults).try(:default_branch).try(:id)).first
        claim_data = claim.data.with_indifferent_access
        claim_data[:accounting_entry] = {}
        claim_data[:accounting_entry]  = ::Claims::BuildAccountingEntry.new(
                                    config: {
                                      branch: branch,
                                      claim: claim,
                                      user: current_user
                                    }
                                  ).execute!

        claim.update!(data: claim_data)
      end

      def modify_book
        claim  = Claim.where(id: params[:id]).first
        book   = params[:book]

        config  = {
          book: book,
          claim: claim,
          user: current_user
        }

        errors  = ::Claims::ValidateModifyBook.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::Claims::ModifyBook.new(
            config: config
          ).execute!

          render json: { id: claim.id }
        end
      end

      def modify_particular
        claim        = Claim.where(id: params[:id]).first
        particular   = params[:particular]

        config  = {
          particular: particular,
          claim: claim,
          user: current_user
        }

        errors  = ::Claims::ValidateModifyParticular.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::Claims::ModifyParticular.new(
            config: config
          ).execute!

          render json: { id: claim.id }
        end
      end

      def save_payee
        claim   = Claim.where(id: params[:id]).first
        payee   = params[:payee]

        config  = {
          payee: payee,
          claim: claim,
          user: current_user
        }

        errors  = ::Claims::ValidateSavePayee.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::Claims::SavePayee.new(
            config: config
          ).execute!

          render json: { id: claim.id }
        end
      end

      def save_date_paid
        claim          = Claim.where(id: params[:id]).first
        date_paid       = params[:date_paid]

        config  = {
          date_paid: date_paid,
          claim: claim,
          user: current_user
        }

        errors  = ::Claims::ValidateSaveDatePaid.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::Claims::SaveDatePaid.new(
            config: config
          ).execute!

          render json: { id: claim.id }
        end
      end

      def save_note
        claim  = Claim.where(id: params[:id]).first
        note   = params[:note]

        claim_data = claim.data.with_indifferent_access
        claim_data[:note] = note
        claim.update!(data: claim_data)

        render json: { id: claim.id }
      end

      def save_check_number
        claim          = Claim.where(id: params[:id]).first
        check_number   = params[:check_number]

        config  = {
          check_number: check_number,
          claim: claim,
          user: current_user
        }

        errors  = ::Claims::ValidateSaveCheckNumber.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::Claims::SaveCheckNumber.new(
            config: config
          ).execute!

          render json: { id: claim.id }
        end
      end

      def save_check_voucher_number
        claim                  = Claim.where(id: params[:id]).first
        check_voucher_number   = params[:check_voucher_number]

        config  = {
          check_voucher_number: check_voucher_number,
          claim: claim,
          user: current_user
        }

        errors  = ::Claims::ValidateSaveCheckVoucherNumber.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::Claims::SaveCheckVoucherNumber.new(
            config: config
          ).execute!

          render json: { id: claim.id }
        end
      end

      def modify_claims_template
        claim     = Claim.where(id: params[:id]).first
        template  = params[:template]

        config  = {
          template: template,
          claim: claim,
          user: current_user
        }

        errors  = ::Claims::ValidateModifyClaimsTemplate.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::Claims::ModifyClaimsTemplate.new(
            config: config
          ).execute!

          render json: { id: claim.id }
        end
      end

      def add_transaction_fee
        claim     = Claim.where(id: params[:id]).first
        transaction_fee  = params[:transaction_fee].to_f

        config  = {
          transaction_fee: transaction_fee,
          claim: claim,
          user: current_user
        }

        errors  = ::Claims::ValidateAddTransactionFee.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::Claims::AddTransactionFee.new(
            config: config
          ).execute!

          render json: { id: claim.id }
        end
      end

      def post
        # new code
        claim = Claim.find(params[:id])

        config = {
          claim: claim,
          user: current_user
        }

        if ["MIS"].include? current_user.roles.last
          errors =  Claims::ValidateClaimForPosting.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: { errors: errors }, status: 400
          else
            claim.update!(status: "processing")

            ProcessPostClaim.perform_later({
              id: claim.id,
              user_id: current_user.id
            })

            render json: { message: "Successfully approved claim", id: claim.id }
          end
        else
          errors << "Unauthorized to perform this transaction"
          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end
    end
  end
end
