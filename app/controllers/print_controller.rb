class PrintController < ApplicationController 
  before_action :authenticate_user!

  def print
    #raise params[:type].inspect
    type  = params[:type]
    data  = {}

    errors = {
      messages: {},
      full_messages: []
    }

    if type == "accounting_entry"
      accounting_entry = AccountingEntry.find(params[:id])

      data  = ::Print::BuildAccountingEntry.new(
                accounting_entry: accounting_entry
              ).execute!

      @accounting_entry_data  = data
      
      render "print/accounting_entry", layout: "print"
    
    elsif type == "print_ledger"
      savings_account = MemberAccount.find(params[:id])
      data= ::Print::PrintSavingsLedger.new(member_account: savings_account ).execute!
      @member_account = data
      render "print/print_ledger", layout: "print"
 
    elsif type == "claims_voucher"
      accounting_entry = AccountingEntry.find(params[:id])

      data  = ::Print::BuildAccountingEntry.new(
                accounting_entry: accounting_entry
              ).execute!

      @accounting_entry_data  = data
      @claim = Claim.find(params[:cid])

      render "print/claims_voucher", layout: "print"
    elsif type == "deposit_collection_accounting_entry"
      deposit_collection = DepositCollection.find(params[:id])
      accounting_entry   = deposit_collection.approved_accounting_entry

      data  = ::Print::BuildAccountingEntry.new(
                accounting_entry: accounting_entry
              ).execute!

      @accounting_entry_data  = data

      render "print/accounting_entry", layout: "print"
    elsif type == "member_share"
      member_share = MemberShare.find(params[:id])

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

      @member_share_data  = data

      render "print/member_share", layout: "print"
    elsif type == "billing"
      billing = Billing.find(params[:id])

      data  = ::Print::BuildBilling.new(
                billing: billing
              ).execute!

      @billing  = data

      render "print/billing", layout: "print"
    elsif type == "wp"
      billing = Billing.find(params[:id])

      data  = ::Print::BuildBilling.new(
                billing: billing
              ).execute!

      @billing  = data

      render "print/wp", layout: "print"
    elsif type == "membership_payment_collection"
      membership_payment_collection = MembershipPaymentCollection.find(params[:id])

      data  = ::Print::BuildMembershipPaymentCollection.new(
                membership_payment_collection: membership_payment_collection
              ).execute!

      @membership_payment_collection = data

      render "print/membership_payment_collection", layout: "print"
    elsif type == "general_ledger"
      start_date          = params[:start_date].try(:to_date)
      end_date            = params[:end_date].try(:to_date)
      branch_id           = params[:branch_id]
      accounting_code_ids = params[:accounting_code_ids].try(:split, ",") || []
      branch              = Branch.find(branch_id)

      config  = {
        start_date: start_date,
        end_date: end_date,
        branch: branch,
        accounting_code_ids: accounting_code_ids
      }

      general_ledger_data  = ::Accounting::GenerateGeneralLedger.new(
                              config: config
                            ).execute!

      data  = ::Accounting::FormatGeneralLedger.new(
                general_ledger_data: general_ledger_data
              ).execute!

      @general_ledger = data

      render "print/general_ledger", layout: "print"
    elsif type == "trial_balance"
      start_date  = params[:start_date].try(:to_date)
      end_date    = params[:end_date].try(:to_date)
      branch      = Branch.where(id: params[:branch_id]).first

      config  = {
        start_date: start_date,
        end_date: end_date,
        branch: branch
      }

      trial_balance_data  = ::Accounting::FetchTrialBalance.new(
                              config: config
                            ).execute!

      data  = ::Accounting::FetchTrialBalance.new(
                config: config
              ).execute!

      @trial_balance  = data

      render "print/trial_balance", layout: "print"
    elsif type == "book"
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

      @book = data

      render "print/book", layout: "print"
    elsif type == "deposit_collection"
      deposit_collection  = DepositCollection.find(params[:id])

      config  = {
        deposit_collection: deposit_collection
      }

      data  = ::Print::BuildDepositCollection.new(
                config: config
              ).execute!

      @deposit_collection = data
      
      render "print/deposit_collection", layout: "print"
    elsif type == "insurance_fund_transfer_collection"
      insurance_fund_transfer_collection  = InsuranceFundTransferCollection.find(params[:id])

      config  = {
        insurance_fund_transfer_collection: insurance_fund_transfer_collection
      }

      data  = ::Print::BuildFundTransferCollection.new(
                                            config: config
                                            ).execute!

      @insurance_fund_transfer_collection = data

      render "print/insurance_fund_transfer_collection", layout: "print"
    elsif type == "time_deposit_collection"
      time_deposit_collection = TimeDepositCollection.find(params[:id])

      config  = {
        time_deposit_collection: time_deposit_collection
      }

      data  = ::Print::BuildTimeDepositCollection.new(
                config: config
              ).execute!

      @deposit_collection = data

      render "print/deposit_collection", layout: "print"
    elsif type == "withdrawal_collection"
      withdrawal_collection = WithdrawalCollection.find(params[:id])

      config  = {
        withdrawal_collection: withdrawal_collection
      }

      data  = ::Print::BuildWithdrawalCollection.new(
                config: config
              ).execute!

      @withdrawal_collection = data

      render "print/withdrawal_collection", layout: "print"
    elsif type == "withdrawal_request"
      data_store = DataStore.find(params[:id])

      config  = {
        data_store: data_store
      }

      data  = ::Print::BuildWithdrawalRequest.new(
                config: config
              ).execute!

      @withdrawal_request = data

      render "print/withdrawal_request", layout: "print"
    else
      raise "Invalid type: #{type}"
    end
  end
end
