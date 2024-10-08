module Api
  module V1
    class InsuranceFundTransferCollectionsController < ApiController
      before_action :authenticate_user!

      def fetch
        insurance_fund_transfer_collection = InsuranceFundTransferCollection.find(params[:id])

        render json: insurance_fund_transfer_collection
      end

      def remove_member
        config  = {
          insurance_fund_transfer_collection: InsuranceFundTransferCollection.where(id: params[:id]).first,
          member:             Member.where(id: params[:member_id]).first,
          user:               current_user
        }

        errors  = ::InsuranceFundTransferCollections::ValidateRemoveMember.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          o = ::InsuranceFundTransferCollections::RemoveMember.new(
                config: config
              ).execute!

          render json: { id: o.id }
        end
      end

      def add_member
        config  = {
          insurance_fund_transfer_collection:  InsuranceFundTransferCollection.where(id: params[:id]).first,
          member: Member.where(id: params[:member_id]).first,
          user: current_user
        }

        errors  = ::InsuranceFundTransferCollections::ValidateAddMember.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          o = ::InsuranceFundTransferCollections::AddMember.new(
                config: config
              ).execute!

          render json: { id: o.id }
        end
      end

      def load_center
        config  = {
          insurance_fund_transfer_collection:  InsuranceFundTransferCollection.where(id: params[:id]).first,
          center: Center.where(id: params[:center_id]).first,
          user: current_user
        }

        errors  = ::InsuranceFundTransferCollections::ValidateLoadCenter.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::InsuranceFundTransferCollections::LoadCenter.new(
            config: config
          ).execute!
        end
      end

      def fetch_members
        insurance_fund_transfer_collection = InsuranceFundTransferCollection.find(params[:id])

        members_active = Member.inforce_pending.where(
                    branch_id: insurance_fund_transfer_collection.branch_id
                  ).where.not(
                    id: insurance_fund_transfer_collection.member_ids
                  ).order("last_name ASC").map{ |o|
                    {
                      id: o.id,
                      name: o.full_name,
                      identification_number: o.identification_number,
                      center: {
                        id: o.center.id,
                        name: o.center.name
                      }
                    }
                  }

        members_reinstate = Member.reinstate.where(
                    branch_id: insurance_fund_transfer_collection.branch_id
                  ).where.not(
                    id: insurance_fund_transfer_collection.member_ids
                  ).order("last_name ASC").map{ |o|
                    {
                      id: o.id,
                      name: o.full_name,
                      identification_number: o.identification_number,
                      center: {
                        id: o.center.id,
                        name: o.center.name
                      }
                    }
                  }

        members = (members_active + members_reinstate).uniq

        render json: { members: members }
      end

      def update_particular
        insurance_fund_transfer_collection = InsuranceFundTransferCollection.find(params[:id])
        data                               = insurance_fund_transfer_collection.try(:data).try(:with_indifferent_access)
        particular                         = params[:particular]

        if insurance_fund_transfer_collection.pending?
          data[:particular]  = particular

          insurance_fund_transfer_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def update_or_number
        insurance_fund_transfer_collection = InsuranceFundTransferCollection.find(params[:id])
        data                               = insurance_fund_transfer_collection.try(:data).try(:with_indifferent_access)
        or_number                          = params[:or_number]

        if insurance_fund_transfer_collection.pending?
          data[:or_number]                            = or_number

          insurance_fund_transfer_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def update_reference_number
        insurance_fund_transfer_collection = InsuranceFundTransferCollection.find(params[:id])
        data                               = insurance_fund_transfer_collection.try(:data).try(:with_indifferent_access)
        reference_number                   = params[:reference_number]

        if insurance_fund_transfer_collection.pending?
          data[:reference_number]                 = reference_number

          insurance_fund_transfer_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def revert
        insurance_fund_transfer_collection   = InsuranceFundTransferCollection.find(params[:id])
        data                                 = insurance_fund_transfer_collection.try(:data).try(:with_indifferent_access)

        if insurance_fund_transfer_collection.pending?
          data[:finalize] = false

          insurance_fund_transfer_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def finalize
        insurance_fund_transfer_collection   = InsuranceFundTransferCollection.find(params[:id])
        data                                 = insurance_fund_transfer_collection.try(:data).try(:with_indifferent_access)

        config  = {
          insurance_fund_transfer_collection: insurance_fund_transfer_collection,
          user: current_user
        }

        if insurance_fund_transfer_collection.pending?
          errors  = ::InsuranceFundTransferCollections::ValidateFinalize.new(
                    config: config
                  ).execute!

          if errors[:messages].any?
            render json: errors, status: 400
          else
            data[:finalize] = true

            insurance_fund_transfer_collection.update!(
              data: data
            )

            render json: { message: "ok" }
          end
        else
          render json: { message: "error" }, status: 400
        end
      end

      def approve
        insurance_fund_transfer_collection = InsuranceFundTransferCollection.where(id: params[:id]).first

        config  = {
          insurance_fund_transfer_collection: insurance_fund_transfer_collection,
          user: current_user
        }

        errors  = ::InsuranceFundTransferCollections::ValidateApprove.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::InsuranceFundTransferCollections::Approve.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end

      def modify_transaction_record
        insurance_fund_transfer_collection = InsuranceFundTransferCollection.where(id: params[:id]).first

        current_transaction = params[:current_transaction]
        current_member      = params[:current_member]

        config  = {
          insurance_fund_transfer_collection: insurance_fund_transfer_collection,
          current_transaction: current_transaction,
          current_member: current_member,
          user: current_user
        }

        errors  = ::InsuranceFundTransferCollections::ValidateModifyTransactionRecord.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: { errors: errors }, status: 400
        else
          insurance_fund_transfer_collection = ::InsuranceFundTransferCollections::ModifyTransactionRecord.new(
                                            config: config
                                          ).execute!

          render json: insurance_fund_transfer_collection
        end
      end

      def create
        collection_date = params[:collection_date].try(:to_date)
        branch_id       = params[:branch_id]

        config  = {
          collection_date: collection_date,
          branch_id: branch_id,
          user: current_user
        }

        errors  = ::InsuranceFundTransferCollections::ValidateCreateInsuranceFundTransferCollection.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: errors, status: 400
        else
          insurance_fund_transfer_collection = ::InsuranceFundTransferCollections::CreateInsuranceFundTransferCollection.new(
                                    config: config
                                  ).execute!

          render json: { id: insurance_fund_transfer_collection.id }
        end
      end
    end
  end
end
