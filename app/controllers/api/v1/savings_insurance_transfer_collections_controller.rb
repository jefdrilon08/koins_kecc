module Api
  module V1
    class SavingsInsuranceTransferCollectionsController < ApiController
      before_action :authenticate_user!

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
          insurance_subtype: insurance_subtype
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
