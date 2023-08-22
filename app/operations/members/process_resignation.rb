module Members
  class ProcessResignation
    def initialize(config:)
      @config = config

      @data = @config[:data]
      @user = @config[:user]

      @member = Member.find(@data[:member][:id])
      @active_loans = Loan.where(member_id: @member.id,status: "active")
      @accrued_loan = Loan.where("member_id = ? and data->>'accrued_interest' != ? ","#{@member.id}","nil")
     
      @member_data  = @member.data.with_indifferent_access
     
    end

    def execute!
      if @active_loans.any? or @accrued_loan.any?
      
        process_loan_payments!
      end
      accounting_entry  = post_accounting_entry!
      process_withdrawals!(accounting_entry.reference_number)
      



      process_deposits!(accounting_entry.reference_number)

      resignation_data  = {
        type: @data[:member_resignation_type][:name],
        code: @data[:member_resignation_type][:particular][:code],
        reason: @data[:member_resignation_type][:particular][:name],
        accounting_reference_number: accounting_entry.reference_number
      }

      resignation_records = @member_data[:resignation_records]

      if resignation_records.blank?
        resignation_records = []
      end

      resignation_records << {
        branch: @data[:branch],
        center: @data[:center],
        date_resigned: @data[:date_resigned],
        member_resignation_type: @data[:member_resignation_type]
      }

      @member_data[:resignation]          = resignation_data
      @member_data[:resignation_records]  = resignation_records

      @member.update!(
        status: "resigned",
        date_resigned: @data[:date_resigned],
        data: @member_data
      )

      # Update all member shares
      @member.member_shares.each do |s|
        s.update!(is_void: true)
      end
    end

    private

    def process_deposits!(accounting_entry_reference_number)
      config  = {
        date_paid: @data[:date_resigned],
        deposit: {
          amount: @data[:deposit][:amount],
          member_account_id: @data[:deposit][:member_account_id],
          lock_in_period: {}
        },
        member: @member,
        user: @user,
        particular: @data[:accounting_entry][:particular],
        accounting_entry_reference_number: accounting_entry_reference_number
      }

      ::DepositCollections::ApproveDepositHash.new(
        config: config
      ).execute!
    end

    def process_withdrawals!(accounting_entry_reference_number)
      @data[:equity_accounts].each do |o|
        config  = {
          date_paid: @data[:date_resigned],
          withdrawal: {
            amount: o[:balance],
            member_account_id: o[:id]
          },
          member: @member,
          user: @user,
          particular: @data[:accounting_entry][:particular],
          accounting_entry_reference_number: accounting_entry_reference_number
        }

        ::WithdrawalCollections::ApproveWithdrawalHash.new(
          config: config
        ).execute!
      end
    end

    def post_accounting_entry!
      accounting_entry_data = @data[:accounting_entry]

      accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                            config: {
                              id: nil,
                              accounting_entry_data: accounting_entry_data,
                              user: @user
                            }
                          ).execute!

      accounting_entry  = ::Accounting::AccountingEntries::Approve.new(
                            config: {
                              accounting_entry: accounting_entry,
                              user: @user
                            }
                          ).execute!

      accounting_entry
    end

    def process_loan_payments!
      member_accounts = @data[:equity_accounts]
      
      total_equity_balance = 0.0
      total_loan_balance = 0.0
      if @active_loans.any?
        @active_loans.each do |ml|
          total_loan_balance = ml.total_balance.to_f
        end
      end

     
      if @accrued_loan.any? 
        @accrued_loan.each do |ac|
          accrued = Loan.find(ac.id)
          accrued_data = accrued.data.with_indifferent_access
          if accrued_data[:accrued_interest][:total_accrued_interest_balance].to_f == 0.0
            accrued_balance = accrued_data[:accrued_interest][:total_accrued_interest]
            total_loan_balance += accrued_balance.to_f
          end
        end
      end    
      

   
      member_accounts.each do |ma|

        if ma["account_subtype"] == "Share Capital"
          if ma["balance"].to_f < total_loan_balance.round(2).to_f
            total_equity_balance += ma["balance"].to_f
          else
            total_equity_balance += ma["balance"].to_f
          end 
        elsif ma["account_subtype"] == "CBU"
          if total_loan_balance.to_f > total_equity_balance
            total_equity_balance += ma["balance"].to_f
          end
        end
      end

   
      if total_equity_balance.round(2).to_f >= total_loan_balance.round(2).to_f
        #active_loans
        if @active_loans.any?
          @active_loans.each do |ml|
            loans = Loan.find(ml.id)
            loan_data = loans.data.with_indifferent_access
            loan_data[:is_tapal] = true
            @account_transaction = AccountTransaction.new(
              subsidiary_id: loans.id,
              subsidiary_type: "Loan",
              amount: loans.total_balance.to_f,
              transaction_type: "loan_payment",
              transacted_at: @data[:date_resigned],
              status: "approved",
              data: {
                amort_entries: [],
                total_principal_paid: loans.principal_balance.to_f,
                total_interest_paid: loans.interest_balance.to_f,
                amount_due: loans.total_balance.to_f,
                approved_by: @user.full_name

              }
            )
            @account_transaction.save!
            @unpaid_ase  = AmortizationScheduleEntry.unpaid.where(
                      "loan_id = ? AND due_date <= ?", 
                      loans.id, 
                      @account_transaction.transacted_at
                    ).order("due_date ASC")
          
            @amort_entries = []

            @unpaid_ase.each do |ase|
              amort = AmortizationScheduleEntry.find(ase.id)
              amort_data = {payments: []}
              
              if ase.data.nil?
                amort_data[:payments] << {
                  payment_id: @account_transaction.id,
                  payment_date: @account_transaction.transacted_at,
                  principal_paid: ase.principal_balance.to_f,
                  interest_paid: ase.interest_balance.to_f
                }

                @amort_entries << {
                  id: ase.id,
                  due_date: ase.due_date,
                  principal_paid: ase.principal_balance,
                  interest_paid: ase.interest_balance
                }
                
              else
                amort_data[:payments] << {
                  payment_id: @account_transaction.id,
                  payment_date: @account_transaction.transacted_at,
                  principal_paid: ase.principal_balance.to_f,
                  interest_paid: ase.interest_balance.to_f
                }

                 @amort_entries << {
                  id: ase.id,
                  due_date: ase.due_date,
                  principal_paid: ase.principal_balance,
                  interest_paid: ase.interest_balance
                }
               
              end

              amort.update!(is_paid: true, principal_balance: 0.0, interest_balance: 0.0, principal_paid: ase.principal,interest_paid: ase.interest,data: amort_data)
              amort
            end

            @account_transaction.update(data:{amort_entries: @amort_entries, total_principal_paid: loans.principal_balance, total_interest_paid:loans.interest_balance, amount_due: loans.total_balance ,particular: "",approved_by: "SYSTEM"})
            loans.update!(status: "paid",principal_balance: 0.0, interest_balance: 0.0, principal_paid: loans.principal, interest_paid: loans.interest,date_completed: @data[:date_resigned],data: loan_data)

          end
        end

        #accrued loans
        if @accrued_loan.any?
          @accrued_loan.each do |ac|
            loans = Loan.find(ac.id)
            loan_data = loans.data.with_indifferent_access
            if loan_data[:accrued_interest][:total_accrued_interest_balance].to_f == 0.0
              loan_data[:accrued_interest]["status"] = "paid"
              loan_data[:accrued_interest]["total_accrued_interest_balance"] = loan_data[:accrued_interest]["total_accrued_interest"]
              loan_data[:is_tapal] = true
              loans.update!(data: loan_data)
            end
          end
        end
      end


      
    end
  end
end
