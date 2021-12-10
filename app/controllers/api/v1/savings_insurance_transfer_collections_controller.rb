module Api
  module V1
    class SavingsInsuranceTransferCollectionsController < ApiController
      before_action :authenticate_user!

      def approve
        savings_insurance_transfer_collection = SavingsInsuranceTransferCollection.where(id: params[:id]).first

        config  = {
          savings_insurance_transfer_collection: savings_insurance_transfer_collection,
          user: current_user
        }

        errors  = ::SavingsInsuranceTransferCollections::ValidateApprove.new(
                    config: config
                  ).execute!


        if errors[:full_messages].any?
          render json: { errors: errors }, status: 400
        else
          savings_insurance_transfer_collection.update!(status: "processing")

          args  = {
            id: savings_insurance_transfer_collection.id,
            user_id: current_user.id
          }

          ProcessApproveSavingsInsuranceTransferCollection.perform_later(args)

          render json: { message: "ok" }
        end
      end

      def remove_member
        savings_insurance_transfer_collection = SavingsInsuranceTransferCollection.where(id: params[:id]).first
        member                                = Member.where(id: params[:member_id]).first

        config  = {
          savings_insurance_transfer_collection: savings_insurance_transfer_collection,
          member: member,
          user: current_user
        }

        errors  = ::SavingsInsuranceTransferCollections::ValidateRemoveMember.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: { errors: errors }, status: 400
        else
          ::SavingsInsuranceTransferCollections::RemoveMember.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end

      def add_member
        savings_insurance_transfer_collection = SavingsInsuranceTransferCollection.where(id: params[:id]).first
        member                                = Member.where(id: params[:member_id]).first
        amount                                = params[:amount].try(:to_f).try(:round, 2)

        if savings_insurance_transfer_collection.clip
          loan_product_id = params[:loan_product_id]
          principal = params[:principal]
          term = params[:term]
          num_installments = params[:num_installments]
          maturity_date = params[:maturity_date]
          effective_date = params[:effective_date]
          clip_number = params[:clip_number]
          beneficiary = params[:beneficiary]

          config  = {
            savings_insurance_transfer_collection: savings_insurance_transfer_collection,
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
        else
          config  = {
            savings_insurance_transfer_collection: savings_insurance_transfer_collection,
            member: member,
            amount: amount,
            user: current_user
          }
        end

        errors  = ::SavingsInsuranceTransferCollections::ValidateAddMember.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: { errors: errors }, status: 400
        else
          ::SavingsInsuranceTransferCollections::AddMember.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end

      def update_particular
        savings_insurance_transfer_collection = SavingsInsuranceTransferCollection.where(id: params[:id]).first
        particular                            = params[:particular]

        config  = {
          savings_insurance_transfer_collection: savings_insurance_transfer_collection,
          particular: particular,
          user: current_user
        }

        errors  = ::SavingsInsuranceTransferCollections::ValidateUpdateParticular.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: { errors: errors }, status: 400
        else
          ::SavingsInsuranceTransferCollections::UpdateParticular.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end

      def save
        branch            = Branch.where(id: params[:branch_id]).first
        center            = Center.where(id: params[:center_id]).first
        collection_date   = params[:collection_date]
        savings_subtype   = params[:savings_subtype]
        insurance_subtype = params[:insurance_subtype]

        config  = {
          branch: branch,
          center: center,
          collection_date: collection_date,
          savings_subtype: savings_subtype,
          insurance_subtype: insurance_subtype,
          user: current_user
        }

        errors  = ::SavingsInsuranceTransferCollections::ValidateSave.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: { errors: errors }, status: 400
        else
          savings_insurance_transfer_collection = ::SavingsInsuranceTransferCollections::Save.new(
                                                    config: config
                                                  ).execute!

          render json: { message: "ok", id: savings_insurance_transfer_collection.id }
        end
      end
    end
  end
end
