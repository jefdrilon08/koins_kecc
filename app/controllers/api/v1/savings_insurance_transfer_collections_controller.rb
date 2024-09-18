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
        member_index                          = params[:member_id]

        config  = {
          savings_insurance_transfer_collection: savings_insurance_transfer_collection,
          member_index: member_index,
          user: current_user
        }

        # errors  = ::SavingsInsuranceTransferCollections::ValidateRemoveMember.new(
        #             config: config
        #           ).execute!

        # if errors[:full_messages].any?
        #   render json: { errors: errors }, status: 400
        # else
          ::SavingsInsuranceTransferCollections::RemoveMember.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        #end
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
        elsif savings_insurance_transfer_collection.kbente
                  kbente_beneficiary_name = params[:kbente_beneficiary_name]
                  date_of_birth = params[:date_of_birth]
                  gender = params[:gender]
                  status = params[:status]
                  address = params[:address]
                  effectivity_date = params[:effectivity_date]
                  premium = params[:premium]
                  relationship = params[:relationship]

                  config  = {
                    savings_insurance_transfer_collection: savings_insurance_transfer_collection,
                    kbente_beneficiary_name: kbente_beneficiary_name,
                    date_of_birth: date_of_birth,
                    gender: gender,
                    status: status,
                    address: address,
                    effectivity_date: effectivity_date,
                    premium: premium,
                    relationship: relationship,
                    #beneficiary_age: beneficiary_age,
                    member: member,
                    amount: amount,
                    user: current_user
                  }
        elsif savings_insurance_transfer_collection.kkalinga
                  kkalinga_name_of_insured = params[:kkalinga_name_of_insured]
                  kkalinga_date_of_birth = params[:kkalinga_date_of_birth]
                  kkalinga_gender = params[:kkalinga_gender]
                  kkalinga_status = params[:kkalinga_status]
                  kkalinga_address = params[:kkalinga_address]
                  kkalinga_effectivity_date = params[:kkalinga_effectivity_date]
                  kkalinga_premium = params[:kkalinga_premium]
                  kkalinga_relationship = params[:kkalinga_relationship]
                  kkalinga_beneficiary_name = params[:kkalinga_beneficiary_name]
                  poc_number = params[:poc_number]

                  config  = {
                    savings_insurance_transfer_collection: savings_insurance_transfer_collection,
                    kkalinga_name_of_insured: kkalinga_name_of_insured,
                    kkalinga_date_of_birth: kkalinga_date_of_birth,
                    kkalinga_gender: kkalinga_gender,
                    kkalinga_status: kkalinga_status,
                    kkalinga_address: kkalinga_address,
                    kkalinga_effectivity_date: kkalinga_effectivity_date,
                    kkalinga_premium: kkalinga_premium,
                    kkalinga_relationship: kkalinga_relationship,
                    kkalinga_beneficiary_name: kkalinga_beneficiary_name,
                    poc_number: poc_number,
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

      def update_or_ar_number
        savings_insurance_transfer_collection = SavingsInsuranceTransferCollection.where(id: params[:id]).first
        or_number                            = params[:or_number]
        ar_number                            = params[:ar_number]

        config  = {
          savings_insurance_transfer_collection: savings_insurance_transfer_collection,
          ar_number: ar_number,
          or_number: or_number,
          user: current_user
        }

        errors  = ::SavingsInsuranceTransferCollections::ValidateUpdateOrArNumber.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: { errors: errors }, status: 400
        else
          ::SavingsInsuranceTransferCollections::UpdateOrArNumber.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end

      def save
        if !Settings.activate_microinsurance
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
        else
          branch            = Branch.where(id: params[:branch_id]).first
          center            = Center.where(id: params[:center_id]).first
          collection_date   = params[:collection_date]
          payment_subtype   = params[:payment_subtype]
          ar_number         = params[:ar_number]
          or_number         = params[:or_number]
          insurance_subtype = params[:insurance_subtype]

          config  = {
            branch: branch,
            center: center,
            collection_date: collection_date,
            payment_subtype: payment_subtype,
            ar_number: ar_number,
            or_number: or_number,
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
end