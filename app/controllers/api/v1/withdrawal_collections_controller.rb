module Api
  module V1
    class WithdrawalCollectionsController < ActionController::Base
      before_action :authenticate_user!

      def edit_accounting_name
        withdrawal_collection = WithdrawalCollection.find(params[:id])

        unless withdrawal_collection.pending?
          return render json: { error: "Not editable unless pending" }, status: 400
        end

        accounting_code_id  = params[:accounting_code_id]
        accounting_code_new = params[:accounting_code_new]

        accounting_code = AccountingCode.find_by(id: accounting_code_id)
        if accounting_code.nil?
          return render json: { error: "AccountingCode with the given ID not found" }, status: :not_found
        end
        

        config = {
          id: params[:id],
          accounting_code_id: accounting_code_id,
          accounting_code_new: accounting_code_new
        }

        ::WithdrawalCollections::AccountingEntryEditName.new(config: config).execute!

        render json: {
          message: "Accounting entry updated successfully",
          updated_withdrawal_collection_data: withdrawal_collection.data
        }, status: :ok
      end

      def edit_entry_amount
        withdrawal_collection = WithdrawalCollection.find(params[:id])
        data = withdrawal_collection.data.with_indifferent_access

        unless withdrawal_collection.pending?
          return render json: { error: "Not editable unless pending" }, status: 400
        end

        amount             = params[:amount]
        accounting_code_id = params[:accounting_code_id]

        config = {
          id: params[:id],
          accounting_code_id: accounting_code_id,
          amount: amount
        }.compact

        ::WithdrawalCollections::AccountingEntryEditAmount.new(config: config).execute!

        render json: {
          message: "Accounting entry updated successfully",
          updated_withdrawal_collection_data: withdrawal_collection.data
        }, status: :ok
      end

      def fetch_accounting_codes
        codes = AccountingCode.order("name ASC").pluck(:id, :name).map { |id, name|
          { id: id, name: name }                        
        }

        render json: { accounting_codes: codes }
      end

      def fetch
        withdrawal_collection = WithdrawalCollection.find(params[:id])

        render json: withdrawal_collection
      end

      def remove_member
        config  = {
          withdrawal_collection: WithdrawalCollection.where(id: params[:id]).first,
          member:             Member.where(id: params[:member_id]).first,
          user:               current_user
        }

        errors  = ::WithdrawalCollections::ValidateRemoveMember.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          o = ::WithdrawalCollections::RemoveMember.new(
                config: config
              ).execute!

          render json: { id: o.id }
        end
      end

      def add_member
        config  = {
          withdrawal_collection:  WithdrawalCollection.where(id: params[:id]).first,
          member: Member.where(id: params[:member_id]).first,
          user: current_user
        }

        errors  = ::WithdrawalCollections::ValidateAddMember.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          o = ::WithdrawalCollections::AddMember.new(
                config: config
              ).execute!

          render json: { id: o.id }
        end
      end

      def fetch_members
        withdrawal_collection = WithdrawalCollection.find(params[:id])

        members = Member.active_and_resigned.where(
                    branch_id: withdrawal_collection.branch_id
                  ).where.not(
                    id: withdrawal_collection.member_ids
                  ).order("last_name ASC").map{ |o|
                    {
                      id: o.id,
                      name: o.full_name,
                      center: {
                        id: o.center.id,
                        name: o.center.name
                      }
                    }
                  }

        render json: { members: members }
      end

      def update_particular
        withdrawal_collection = WithdrawalCollection.find(params[:id])
        data                          = withdrawal_collection.try(:data).try(:with_indifferent_access)
        particular                    = params[:particular]

        if withdrawal_collection.pending?
          data[:accounting_entry][:particular]  = particular

          withdrawal_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def approve
        withdrawal_collection = WithdrawalCollection.where(id: params[:id]).first

        config  = {
          withdrawal_collection: withdrawal_collection,
          user: current_user
        }

        errors  = ::WithdrawalCollections::ValidateApprove.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          withdrawal_collection.update!(status: "processing")
          
          ProcessApproveWithdrawalCollection.perform_later({
            id: withdrawal_collection.id,
            user_id: current_user.id
          })

          render json: { message: "ok" }
        end
      end

      def modify_transaction_record
        withdrawal_collection = WithdrawalCollection.where(id: params[:id]).first

        current_transaction = params[:current_transaction]
        current_member      = params[:current_member]

        config  = {
          withdrawal_collection: withdrawal_collection,
          current_transaction: current_transaction,
          current_member: current_member,
          user: current_user
        }

        errors  = ::WithdrawalCollections::ValidateModifyTransactionRecord.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: { errors: errors }, status: 400
        else
          withdrawal_collection = ::WithdrawalCollections::ModifyTransactionRecord.new(
                                            config: config
                                          ).execute!

          render json: withdrawal_collection
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

        errors  = ::WithdrawalCollections::ValidateCreateWithdrawalCollection.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: errors, status: 400
        else
          withdrawal_collection = ::WithdrawalCollections::CreateWithdrawalCollection.new(
                                    config: config
                                  ).execute!

          render json: { id: withdrawal_collection.id }
        end
      end
    end
  end
end
