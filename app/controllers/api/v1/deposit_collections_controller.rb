module Api
  module V1
    class DepositCollectionsController < ActionController::Base
      before_action :authenticate_user!

      def edit_accounting_name
        deposit_collection = DepositCollection.find(params[:id])
        data = deposit_collection.data.with_indifferent_access

        unless deposit_collection.pending?
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

        ::DepositCollections::AccountingEntryEditName.new(config: config).execute!

        render json: {
          message: "Accounting entry updated successfully",
          updated_deposit_collection_data: deposit_collection.data
        }, status: :ok
      end

      def edit_entry_amount
        deposit_collection = DepositCollection.find(params[:id])
        data = deposit_collection.data.with_indifferent_access

        unless deposit_collection.pending?
          return render json: { error: "Not editable unless pending" }, status: 400
        end

        amount             = params[:amount]
        accounting_code_id = params[:accounting_code_id]

        config = {
          id: params[:id],
          accounting_code_id: accounting_code_id,
          amount: amount
        }.compact

        ::DepositCollections::AccountingEntryEditAmount.new(config: config).execute!

        render json: {
          message: "Accounting entry updated successfully",
          updated_deposit_collection_data: deposit_collection.data
        }, status: :ok
      end

      def fetch_accounting_codes
        codes = AccountingCode.order("name ASC").pluck(:id, :name).map { |id, name|
          { id: id, name: name }                        
        }

        render json: { accounting_codes: codes }
      end


      def load_center
        deposit_collection  = DepositCollection.where(id: params[:id]).first
        center              = Center.where(id: params[:center_id]).first

        config  = {
          deposit_collection: deposit_collection,
          center: center
        }

        errors  = ::DepositCollections::ValidateLoadCenter.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          deposit_collection.update!(status: "processing")

          ProcessDepositCollectionLoadCenter.perform_later({ id: deposit_collection.id, center_id: center.id })

          render json: { id: deposit_collection.id }
        end
      end

      def load_branch
        deposit_collection  = DepositCollection.where(id: params[:id]).first

        config  = {
          deposit_collection: deposit_collection
        }

        errors  = ::DepositCollections::ValidateLoadBranch.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          deposit_collection.update!(status: "processing")

          ProcessDepositCollectionLoadBranch.perform_later({ id: deposit_collection.id, user_id: current_user.id })

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

        if errors[:messages].any?
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
          deposit_collection: deposit_collection,
          user: current_user
        }

        errors  = ::DepositCollections::ValidateModifyCashManagementTemplate.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
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

        if deposit_collection.data["accounting_fund_id"].present?
          deposit_collection.data["accounting_fund_name"] = AccountingFund.find(deposit_collection.data["accounting_fund_id"]).name
        end

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

        if errors[:messages].any?
          render json: errors, status: 400
        else
          o = ::DepositCollections::RemoveMember.new(
                config: config
              ).execute!

          render json: { id: o.id }
        end
      end

      def load_center
        config  = {
          deposit_collection:  DepositCollection.where(id: params[:id]).first,
          center: Center.where(id: params[:center_id]).first,
          user: current_user
        }

        errors  = ::DepositCollections::ValidateLoadCenter.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::DepositCollections::LoadCenter.new(
            config: config
          ).execute!
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

        if errors[:messages].any?
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
      def update_si_number
        deposit_collection   = DepositCollection.find(params[:id])
        data      = deposit_collection.try(:data).try(:with_indifferent_access)
        si_number = params[:si_number]

        if deposit_collection.pending?
          data[:si_number]                            = si_number
          data[:accounting_entry][:data][:si_number]  = si_number

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

      def finalize
        deposit_collection   = DepositCollection.find(params[:id])
        data      = deposit_collection.try(:data).try(:with_indifferent_access)
        
        config  = {
            deposit_collection: deposit_collection,
            user: current_user
          }

        if deposit_collection.pending?
          errors  = ::DepositCollections::ValidateFinalize.new(
                    config: config
                  ).execute!
          if errors[:messages].any?
            render json: errors, status: 400
          else
            data[:finalize] = true

            deposit_collection.update!(
              data: data
            )

            render json: { message: "ok" }
          end
        else
          render json: { message: "error" }, status: 400
        end
      end

      def update_accounting_fund
        deposit_collection   = DepositCollection.find(params[:id])
        data                 = deposit_collection.try(:data).try(:with_indifferent_access)
        accounting_fund_id   = params[:accounting_fund_id]

        if deposit_collection.pending?
          data[:accounting_fund_id]                     = accounting_fund_id
          data[:accounting_entry][:accounting_fund_id]  = accounting_fund_id

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

        if errors[:messages].any?
          render json: errors, status: 400
        else
          deposit_collection.update!(status: "processing")

          ProcessApproveDepositCollection.perform_later({
            id: deposit_collection.id,
            user_id: current_user.id
          })

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

        if errors[:messages].any?
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

        if errors[:full_messages].any?
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
