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


        if errors[:full_messages].size > 0
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

        if errors[:full_messages].size > 0
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

        config  = {
          savings_insurance_transfer_collection: savings_insurance_transfer_collection,
          member: member,
          amount: amount,
          user: current_user
        }

        errors  = ::SavingsInsuranceTransferCollections::ValidateAddMember.new(
                    config: config
                  ).execute!

        if errors[:full_messages].size > 0
          render json: { errors: errors }, status: 400
        else
          ::SavingsInsuranceTransferCollections::AddMember.new(
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

        if errors[:full_messages].size > 0
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
