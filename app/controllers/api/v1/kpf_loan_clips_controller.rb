module Api
  module V1
    class KpfLoanClipsController < ApiController
      before_action :authenticate_user!

      def approve
        kpf_loan_clip = KpfLoanClip.where(id: params[:id]).first
        config  = {
          kpf_loan_clip: kpf_loan_clip,
          user: current_user
        }
          kpf_loan_clip.update!(status: "processing")
          args  = {
            id: kpf_loan_clip.id,
            user_id: current_user.id
          }

        ProcessApproveKpfLoanClip.perform_later(args)

        render json: { message: "ok" }
      end

      def check
        kpf_loan_clip = KpfLoanClip.find(params[:id])

        config = {
          kpf_loan_clip: kpf_loan_clip,
          user: current_user
        }

        if ["OAS", "MIS", "REMOTE-MIS", "REMOTE-BK", "REMOTE-FM"].include? current_user.roles.last
          errors  = KpfLoanClips::ValidateCheck.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: { errors: errors }, status: 400
          else
            kpf_loan_clip  = KpfLoanClips::Check.new(
                                        config: config
                                      ).execute!

            render json: { message: "Successfully proceed" }
          end
        else
          errors << "Unauthorized to perform this transaction"

          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end

      def remove_member
        kpf_loan_clip = KpfLoanClip.where(id: params[:id]).first
        member                                = Member.where(id: params[:member_id]).first
        member_index                          = params[:member_id]

        config  = {
          kpf_loan_clip: kpf_loan_clip,
          member_index: member_index,
          user: current_user
        }
          ::KpfLoanClips::RemoveMember.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        #end
      end

      def add_member
        kpf_loan_clip    = KpfLoanClip.where(id: params[:id]).first
        member           = Member.where(id: params[:member_id]).first
        amount           = params[:amount].try(:to_f).try(:round, 2)
        loan_product_id  = params[:loan_product_id]
        principal        = params[:principal]
        term             = params[:term]
        num_installments = params[:num_installments]
        maturity_date    = params[:maturity_date]
        effective_date   = params[:effective_date]
        clip_number      = params[:clip_number]
        beneficiary      = params[:beneficiary]

        config = {
          kpf_loan_clip: kpf_loan_clip,
          loan_product_id: loan_product_id,
          principal: principal,
          term: term,
          num_installments: num_installments,
          maturity_date: maturity_date,
          effective_date: effective_date,
          clip_number: clip_number,
          beneficiary: beneficiary,
          member: member,
          amount: amount,
          user: current_user
        }

        errors  = ::KpfLoanClips::ValidateAddMember.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: { errors: errors }, status: 400
        else
          ::KpfLoanClips::AddMember.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end

      def save
        branch            = Branch.where(id: params[:branch_id]).first
        center            = Center.where(id: params[:center_id]).first
        collection_date   = params[:collection_date]

        config  = {
          branch: branch,
          center: center,
          collection_date: collection_date,
          user: current_user
        }

        errors  = ::KpfLoanClips::ValidateSave.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: { errors: errors }, status: 400
        else
          kpf_loan_clip = ::KpfLoanClips::Save.new(
                                                    config: config
                                                  ).execute!

          render json: { message: "ok", id: kpf_loan_clip.id }
        end

      end
    end
  end
end
