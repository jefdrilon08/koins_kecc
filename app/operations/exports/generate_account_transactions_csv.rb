module Exports
	class GenerateAccountTransactionsCsv
    attr_accessor :account_transactions

		def initialize(account_transactions:)
			@account_transactions = account_transactions
		end

		def execute!
	       CSV.generate do |csv|
                        csv << [ 
                            :insurance_account_uuid,
                            :amount,
                            :transaction_type,
                            :transacted_at,
                            :particular,
                            :status,
                            :transacted_by,
                            :approved_by,
                            :voucher_reference_number,
                            :transaction_number,
                            :bank_id,
                            :accounting_code_id,
                            :uuid,
                            :beginning_balance,
                            :ending_balance,
                            :transaction_date,
                            :is_adjustment,
                            :is_for_loan_payments,
                            :is_for_exit_age,
                            :is_withdraw_payment,
                            :is_fund_transfer,
                            :is_interest,
                            # for clip and hiip data
                            :id_data,
                            :principal_data,
                            :interest_data,
                            :first_date_of_payment_data,
                            :maturity_date_data,
                            :original_maturity_date_data,
                            :accounting_entry_id_data,
                            :journal_entry_id_data,
                            :amount_data,
                            :loan_product_id_data,
                            :loan_product_name_data,
                            :member_id_data,
                            :date_approved_data,
                            :date_released_data,
                            :reference_number_data,
                            :book_data,
                            :member_account_id_data,
                            :term_data,
                            :num_installments_data,
                            :account_transaction_id_data,
                            :status_data,
                            #ev_amount
                            :equity_value
                        ]

                @account_transactions.each do |at|
                    at_data = at.data.with_indifferent_access

                    if at_data[:data].present?
                        id_data = at_data[:data][:id]
                        principal_data = at_data[:data][:principal]
                        interest_data = at_data[:data][:interest]
                        first_date_of_payment_data = at_data[:data][:first_date_of_payment]
                        maturity_date_data = at_data[:data][:maturity_date]
                        original_maturity_date_data = at_data[:data][:original_maturity_date]
                        accounting_entry_id_data = at_data[:data][:accounting_entry_id]
                        journal_entry_id_data = at_data[:data][:journal_entry_id]
                        amount_data = at_data[:data][:amount]
                        loan_product_id_data = at_data[:data][:loan_product_id]
                        loan_product_name_data = at_data[:data][:loan_product_name]
                        member_id_data = at_data[:data][:member_id]
                        date_approved_data = at_data[:data][:date_approved]
                        date_released_data = at_data[:data][:date_released]
                        reference_number_data = at_data[:data][:reference_number]
                        book_data = at_data[:data][:book]
                        member_account_id_data = at_data[:data][:member_account]
                        term_data = at_data[:data][:term]
                        num_installments_data = at_data[:data][:num_installments]
                        account_transaction_id_data = at_data[:data][:account_transaction_id]
                        status_data = at_data[:data][:status]
                    else
                        id_data = nil
                        principal_data = nil
                        interest_data = nil
                        first_date_of_payment_data = nil
                        maturity_date_data = nil
                        original_maturity_date_data = nil
                        accounting_entry_id_data = nil
                        journal_entry_id_data = nil
                        amount_data =  nil
                        loan_product_id_data = nil
                        loan_product_name_data = nil
                        member_id_data = nil
                        date_approved_data = nil
                        date_released_data = nil
                        reference_number_data = nil
                        book_data = nil
                        member_account_id_data = nil
                        term_data = nil
                        num_installments_data = nil
                        account_transaction_id_data = nil
                        status_data = nil
                    end

                    if at_data[:equity_value].nil?
                        equity_value = nil
                    else
                        equity_value = at_data[:equity_value]
                    end

                    member_account = MemberAccount.where(id: at.subsidiary_id)
                    if member_account
                        csv << [
                        member_account.ids.first,
                        at.amount,
                        at.transaction_type,
                        at.transacted_at.strftime("%Y-%m-%d"),
                        at_data[:accounting_entry_particular],
                        at.status,
                        nil,
                        nil,
                        at_data[:accounting_entry_reference_number],
                        nil,
                        nil,
                        nil,
                        at.id,
                        at_data[:beginning_balance],
                        at_data[:ending_balance],
                        at.transacted_at.strftime("%Y-%m-%d"),
                        at_data[:is_adjustment],
                        at_data[:is_for_loan_payments],
                        at_data[:is_for_exit_age],
                        at_data[:is_withdraw_payment],
                        at_data[:is_fund_transfer],
                        at_data[:is_interest],
                        id_data,
                        principal_data,
                        interest_data,
                        first_date_of_payment_data,
                        maturity_date_data,
                        original_maturity_date_data,
                        accounting_entry_id_data,
                        journal_entry_id_data,
                        amount_data,
                        loan_product_id_data,
                        loan_product_name_data,
                        member_id_data,
                        date_approved_data,
                        date_released_data,
                        reference_number_data,
                        book_data,
                        member_account_id_data,
                        term_data,
                        num_installments_data,
                        account_transaction_id_data,
                        status_data,
                        equity_value
                        ]
                    end
                end
            end
		end
	end
end
