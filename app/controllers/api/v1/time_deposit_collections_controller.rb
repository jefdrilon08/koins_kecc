module Api
  module V1
    class TimeDepositCollectionsController < ActionController::Base
      before_action :authenticate_user!

      def modify_book
        time_deposit_collection = TimeDepositCollection.where(id: params[:id]).first
        book                    = params[:book]

        config  = {
          book: book,
          time_deposit_collection: time_deposit_collection,
          user: current_user
        }

        errors  = ::TimeDepositCollections::ValidateModifyBook.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::TimeDepositCollections::ModifyBook.new(
            config: config
          ).execute!

          render json: { id: time_deposit_collection.id }
        end
      end

      def modify_cash_management_template
        time_deposit_collection  = TimeDepositCollection.where(id: params[:id]).first
        template            = params[:template]

        config  = {
          template: template,
          time_deposit_collection: time_deposit_collection,
          user: current_user
        }

        errors  = ::TimeDepositCollections::ValidateModifyCashManagementTemplate.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::TimeDepositCollections::ModifyCashManagementTemplate.new(
            config: config
          ).execute!

          render json: { id: time_deposit_collection.id }
        end
      end

      def fetch
        time_deposit_collection = TimeDepositCollection.find(params[:id])

        render json: time_deposit_collection
      end

      def remove_member
        config  = {
          time_deposit_collection: TimeDepositCollection.where(id: params[:id]).first,
          member: Member.where(id: params[:member_id]).first,
          user: current_user
        }

        errors  = ::TimeDepositCollections::ValidateRemoveMember.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          o = ::TimeDepositCollections::RemoveMember.new(
                config: config
              ).execute!

          render json: { id: o.id }
        end
      end

      def add_member
        config  = {
          time_deposit_collection:  TimeDepositCollection.where(id: params[:id]).first,
          member: Member.where(id: params[:member_id]).first,
          lock_in_period: params[:lock_in_period].try(:to_i),
          amount: params[:amount].try(:to_f),
          user: current_user
        }

        errors  = ::TimeDepositCollections::ValidateAddMember.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          o = ::TimeDepositCollections::AddMember.new(
                config: config
              ).execute!

          render json: { id: o.id }
        end
      end

      def fetch_members
        time_deposit_collection = TimeDepositCollection.find(params[:id])
        branch                  = time_deposit_collection.branch

        members = ::MemberAccounts::TimeDeposit::FetchMembers.new(
                    config: {
                      branch: branch
                    }
                  ).execute!.map{ |o|
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

      def fetch_accounting_funds
        accounting_funds = AccountingFund.all.map{ |o|
                    {
                      id: o.id,
                      name: o.name
                    }
                  }

        render json: { accounting_funds: accounting_funds }
      end

      def update_particular
        time_deposit_collection = TimeDepositCollection.find(params[:id])
        data                    = time_deposit_collection.try(:data).try(:with_indifferent_access)
        particular              = params[:particular]

        if time_deposit_collection.pending?
          data[:accounting_entry][:particular]  = particular

          time_deposit_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def update_or_number
        time_deposit_collection = TimeDepositCollection.find(params[:id])
        data                    = time_deposit_collection.try(:data).try(:with_indifferent_access)
        or_number = params[:or_number]

        if time_deposit_collection.pending?
          data[:or_number]                            = or_number
          data[:accounting_entry][:data][:or_number]  = or_number

          time_deposit_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end
      def update_si_number
        time_deposit_collection = TimeDepositCollection.find(params[:id])
        data                    = time_deposit_collection.try(:data).try(:with_indifferent_access)
        si_number = params[:si_number]

        if time_deposit_collection.pending?
          data[:si_number]                            = si_number
          data[:accounting_entry][:data][:si_number]  = si_number

          time_deposit_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def update_ar_number
        time_deposit_collection = TimeDepositCollection.find(params[:id])
        data                    = time_deposit_collection.try(:data).try(:with_indifferent_access)
        ar_number               = params[:ar_number]

        if time_deposit_collection.pending?
          data[:ar_number]                            = ar_number
          data[:accounting_entry][:data][:ar_number]  = ar_number

          time_deposit_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def update_accounting_fund
        time_deposit_collection   = TimeDepositCollection.find(params[:id])
        data                 = time_deposit_collection.try(:data).try(:with_indifferent_access)
        accounting_fund_id   = params[:accounting_fund_id]

        if time_deposit_collection.pending?
          data[:accounting_fund_id]                     = accounting_fund_id
          data[:accounting_entry][:accounting_fund_id]  = accounting_fund_id

          time_deposit_collection.update!(
            data: data
          )

          render json: { message: "ok" }
        else
          render json: { message: "error" }, status: 400
        end
      end

      def approve
        time_deposit_collection = TimeDepositCollection.where(id: params[:id]).first

        config  = {
          time_deposit_collection: time_deposit_collection,
          user: current_user
        }

        errors  = ::TimeDepositCollections::ValidateApprove.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::TimeDepositCollections::Approve.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end

      def modify_transaction_record
        time_deposit_collection = TimeDepositCollection.where(id: params[:id]).first

        current_transaction = params[:current_transaction]
        current_member      = params[:current_member]

        config  = {
          time_deposit_collection: time_deposit_collection,
          current_transaction: current_transaction,
          current_member: current_member,
          user: current_user
        }

        errors  = ::TimeDepositCollections::ValidateModifyTransactionRecord.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: { errors: errors }, status: 400
        else
          time_deposit_collection = ::TimeDepositCollections::ModifyTransactionRecord.new(
                                            config: config
                                          ).execute!

          render json: time_deposit_collection
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

        errors  = ::TimeDepositCollections::ValidateCreateTimeDepositCollection.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: errors, status: 400
        else
          time_deposit_collection = ::TimeDepositCollections::CreateTimeDepositCollection.new(
                                            config: config
                                          ).execute!

          render json: { id: time_deposit_collection.id }
        end
      end
    end
  end
end
