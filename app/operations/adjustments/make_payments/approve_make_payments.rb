module Adjustments
  module MakePayments
    class ApproveMakePayments
      def initialize(config:)
      
        @config = config
        @make_payment_details = @config[:make_payment]
        @make_payment_details_data = MakePayment.find(@make_payment_details.id)
        @user = @config[:user]
      end
      def execute!
        @make_payment_details["data"].each do |mpd|
          @account_transaction = AccountTransaction.new
          @data_amort = 
                      { 
                       amort_entries: [], 
                       total_interest_paid: 0.0, 
                       total_principal_paid: 0.0, 
                       amount_due: 0.0,
                       particular: @make_payment_details["meta"]["particular"], 
                       approved_by: @user.full_name 
                      }
          loan_amort = AmortizationScheduleEntry.where("loan_id = ? and is_paid is null", mpd["loan_id"]).order(:due_date)
          
          loan_amort.each do |lm|
            amort_details = { id: lm.id, due_date: lm.due_date, principal_paid: lm.principal_balance, interest_paid: lm.interest_balance   }
            @data_amort[:amort_entries] << amort_details
          end
          
          @data_amort[:total_principal_paid] = @data_amort[:amort_entries].sum{ |a| a[:principal_paid] }.to_f
          @data_amort[:total_interest_paid] = @data_amort[:amort_entries].sum{ |a| a[:interest_paid] }.to_f
          @data_amort[:amount_due] = @data_amort[:total_principal_paid] +  @data_amort[:total_interest_paid]
          
          
          @account_transaction.subsidiary_id = mpd["loan_id"]
          @account_transaction.subsidiary_type = "Loan"
          @account_transaction.amount = (@data_amort[:amort_entries].sum{ |a| a[:principal_paid] }.to_f + @data_amort[:amort_entries].sum{ |a| a[:interest_paid] }.to_f).to_f
          @account_transaction.transaction_type = "loan_payment"
          @account_transaction.transacted_at = "2021-11-25"
          @account_transaction.status = "approved"
          @account_transaction.data = @data_amort

          @account_transaction.save!

          ::Loans::FixAmort.new(loan: Loan.find(mpd["loan_id"])).execute!
          @account_transaction
        end
        
        approve_accounting_entry!
      end

      private
      
      def approve_accounting_entry!
        accounting_entry_data = ::Adjustments::MakePayments:: BuildAccountingEntryForMakePayments.new(make_payment_data: @make_payment_details, current_user: @user   ).execute!
        config = {
            accounting_entry_data: accounting_entry_data,
            user: @user
        }
        accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                              config: config
                            ).execute!
        config  = {
          accounting_entry: accounting_entry,
          user: @user
        }
        @accounting_entry = ::Accounting::AccountingEntries::Approve.new(
                            config: config
                          ).execute!
        
        
        a = @make_payment_details_data
        a_meta = a.meta.with_indifferent_access 
        a_meta[:accounting_entry_id] = @accounting_entry.id
        a.update(meta: a_meta, status: "approve")
    
        @accounting_entry
      end
      
    end
  end
end
