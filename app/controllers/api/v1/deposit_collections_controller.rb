module Api
  module V1
    class DepositCollectionsController < ApplicationController
      before_action :authenticate_user!

      def load_branch
        deposit_collection  = DepositCollection.where(id: params[:id]).first

        config  = {
          deposit_collection: deposit_collection
        }

        errors  = ::DepositCollections::ValidateLoadBranch.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          deposit_collection.update!(status: "processing")

          ProcessDepositCollectionLoadBranch.perform_later({ id: deposit_collection.id })

#          ::DepositCollections::LoadBranch.new(
#            config: config
#          ).execute!

          render json: { id: deposit_collection.id }
        end
      end
      
      def modify_book
        deposit_collection  = DepositCollection.where(id: params[:id]).first
        book                = params[:book]

        config  = {
          book: book,
          deposit_collection: deposit_collection,
          user: current_user
        }

        errors  = ::DepositCollections::ValidateModifyBook.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          ::DepositCollections::ModifyBook.new(
            config: config
          ).execute!

          render json: { id: deposit_collection.id }
        end
      end

      def modify_cash_management_template
        deposit_collection  = DepositCollection.where(id: params[:id]).first
        template            = params[:template]

        config  = {
          template: template,
          deposit_collection: deposit_collection
        }

        errors  = ::DepositCollections::ValidateModifyCashManagementTemplate.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          ::DepositCollections::ModifyCashManagementTemplate.new(
            config: config
          ).execute!

          render json: { id: deposit_collection.id }
        end
      end

      def fetch
        deposit_collection = DepositCollection.find(params[:id])

        render json: deposit_collection
      end

      def remove_member
        config  = {
          deposit_collection: DepositCollection.where(id: params[:id]).first,
          member:             Member.where(id: params[:member_id]).first,
          user:               current_user
        }

        errors  = ::DepositCollections::ValidateRemoveMember.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          o = ::DepositCollections::RemoveMember.new(
                config: config
              ).execute!

          render json: { id: o.id }
        end
      end

      def add_member
        config  = {
          deposit_collection:  DepositCollection.where(id: params[:id]).first,
          member: Member.where(id: params[:member_id]).first,
          user: current_user
        }

        errors  = ::DepositCollections::ValidateAddMember.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          o = ::DepositCollections::AddMember.new(
                config: config
              ).execute!

          render json: { id: o.id }
        end
      end

      def fetch_members
        deposit_collection = DepositCollection.find(params[:id])

        members = Member.active.where(
                    branch_id: deposit_collection.branch_id
                  ).where.not(
                    id: deposit_collection.member_ids
                  ).order("last_name ASC").map{ |o|
                    {
                      id: o.id,
                      name: o.full_name
                    }
                  }

        render json: { members: members }
      end

      def update_particular
        deposit_collection = DepositCollection.find(params[:id])
        data                          = deposit_collection.try(:data).try(:with_indifferent_access)
        particular                    = params[:particular]

        if deposit_collection.pending?
          data[:accounting_entry][:particular]  = particular

          deposit_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def update_or_number
        deposit_collection   = DepositCollection.find(params[:id])
        data      = deposit_collection.try(:data).try(:with_indifferent_access)
        or_number = params[:or_number]

        if deposit_collection.pending?
          data[:or_number]                            = or_number
          data[:accounting_entry][:data][:or_number]  = or_number

          deposit_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def update_ar_number
        deposit_collection   = DepositCollection.find(params[:id])
        data      = deposit_collection.try(:data).try(:with_indifferent_access)
        ar_number = params[:ar_number]

        if deposit_collection.pending?
          data[:ar_number]                            = ar_number
          data[:accounting_entry][:data][:ar_number]  = ar_number

          deposit_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def approve
        deposit_collection = DepositCollection.where(id: params[:id]).first

        config  = {
          deposit_collection: deposit_collection,
          user: current_user
        }

        errors  = ::DepositCollections::ValidateApprove.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          ::DepositCollections::Approve.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end

      def modify_transaction_record
        deposit_collection = DepositCollection.where(id: params[:id]).first

        current_transaction = params[:current_transaction]
        current_member      = params[:current_member]

        config  = {
          deposit_collection: deposit_collection,
          current_transaction: current_transaction,
          current_member: current_member,
          user: current_user
        }

        errors  = ::DepositCollections::ValidateModifyTransactionRecord.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: { errors: errors }, status: 400
        else
          deposit_collection = ::DepositCollections::ModifyTransactionRecord.new(
                                            config: config
                                          ).execute!

          render json: deposit_collection
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

        errors  = ::DepositCollections::ValidateCreateDepositCollection.new(
                    config: config
                  ).execute!

        if errors[:full_messages].size > 0
          render json: errors, status: 400
        else
          deposit_collection = ::DepositCollections::CreateDepositCollection.new(
                                            config: config
                                          ).execute!

          render json: { id: deposit_collection.id }
        end
      end
    end
  end
end
