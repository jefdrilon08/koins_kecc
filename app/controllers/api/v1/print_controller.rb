module Api
  module V1
    class PrintController < ApplicationController
      before_action :authenticate_user!

      def generate_file
        type  = params[:type]
        data  = {}

        errors  = {
          messages: {},
          full_messages: []
        }

        if type == "accounting_entry"
          accounting_entry  = AccountingEntry.find(params[:id])
          filename          = "accounting-entry-#{Time.now.to_i}.json"

          data  = ::Print::BuildAccountingEntry.new(
                    accounting_entry: accounting_entry
                  ).execute!
        elsif type == "deposit_collection_accounting_entry"
          deposit_collection = DepositCollection.find(params[:id])
          accounting_entry   = deposit_collection.approved_accounting_entry
          filename           = "deposit-collection-accounting-entry-#{Time.now.to_i}.json"

          data  = ::Print::BuildAccountingEntry.new(
                    accounting_entry: accounting_entry
                  ).execute!
        elsif type == "member_share"
          member_share  = MemberShare.find(params[:id])
          filename      = "member-share-#{Time.now.to_i}.json"

          data  = ::Print::BuildMemberShare.new(
                    member_share: member_share
                  ).execute!

          # Update printing information
          member_share.update!(
            data: {
              printed: true,
              date_printed: Date.today
            }
          )
        elsif type == "billing"
          billing   = Billing.find(params[:id])
          filename  = "billing-#{Time.now.to_i}.json"

          data  = ::Print::BuildBilling.new(
                    billing: billing
                  ).execute!
        elsif type == "wp"
          billing   = Billing.find(params[:id])
          filename  = "wp-#{Time.now.to_i}.json"

          data  = ::Print::BuildBilling.new(
                    billing: billing
                  ).execute!
        elsif type == "membership_payment_collection"
          membership_payment_collection = MembershipPaymentCollection.find(params[:id])
          filename                      = "membership-payment-collection-#{Time.now.to_i}.json"

          data  = ::Print::BuildMembershipPaymentCollection.new(
                    membership_payment_collection: membership_payment_collection
                  ).execute!
        elsif type == "general_ledger"
          filename  = "general-ledger-#{Time.now.to_i}.json"

          start_date          = params[:start_date].try(:to_date)
          end_date            = params[:end_date].try(:to_date)
          branch_id           = params[:branch_id]
          accounting_code_ids = params[:accounting_code_ids] || []
          branch              = Branch.where(id: branch_id).first

          config  = {
            start_date: start_date,
            end_date: end_date,
            branch: branch,
            accounting_code_ids: accounting_code_ids
          }

          errors  = ::Accounting::ValidateFetchGeneralLedger.new(
                      config: config
                    ).execute!

          if errors[:full_messages].size == 0
            general_ledger_data  = ::Accounting::GenerateGeneralLedger.new(
                                    config: config
                                  ).execute!

            data  = ::Accounting::FormatGeneralLedger.new(
                      general_ledger_data: general_ledger_data
                    ).execute!
          end
        elsif type == "trial_balance"
          filename  = "trial-balance-#{Time.now.to_i}.json"

          start_date  = params[:start_date].try(:to_date)
          end_date    = params[:end_date].try(:to_date)
          branch      = Branch.where(id: params[:branch_id]).first

          config  = {
            start_date: start_date,
            end_date: end_date,
            branch: branch
          }

          errors  = ::Accounting::ValidateFetchTrialBalance.new(
                      config: config
                    ).execute!

          if errors[:full_messages].size == 0
            trial_balance_data  = ::Accounting::GenerateTrialBalance.new(
                                    config: config
                                  ).execute!

            data  = ::Accounting::FormatTrialBalance.new(
                      trial_balance_data: trial_balance_data
                    ).execute!
          end
        elsif type == "book"
          filename  = "book-#{Time.now.to_i}.json"

          start_date  = params[:start_date].try(:to_date)
          end_date    = params[:end_date].try(:to_date)
          book        = params[:book]
          branch      = Branch.where(id: params[:branch_id]).first

          config  = {
            start_date: start_date,
            end_date: end_date,
            book: book,
            branch: branch
          }

          data  = ::Print::BuildBook.new(
                    config: config
                  ).execute!
        elsif type == "deposit_collection"
          deposit_collection  = DepositCollection.find(params[:id])
          filename            = "deposit-collection-#{Time.now.to_i}.json"

          config  = {
            deposit_collection: deposit_collection
          }

          data  = ::Print::BuildDepositCollection.new(
                    config: config
                  ).execute!
        elsif type == "withdrawal_collection"
          withdrawal_collection = WithdrawalCollection.find(params[:id])
          filename              = "withdrawal-collection-#{Time.now.to_i}.json"

          config  = {
            withdrawal_collection: withdrawal_collection
          }

          data  = ::Print::BuildWithdrawalCollection.new(
                    config: config
                  ).execute!
        else
          raise "Invalid type: #{type}"
        end

        if errors[:full_messages].size == 0
          json_data = {
            type: type,
            data: data
          }

          File.open("#{Rails.root}/tmp/#{filename}", "w") do |f|
            f.write(JSON.pretty_generate(json_data))
          end

          render json: { filename: filename }
        else
          render json: errors, status: 400
        end
      end
    end
  end
end
