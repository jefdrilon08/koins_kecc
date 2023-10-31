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
            @loans = Loan.find(ml.id)

            payment_stats = ::Loans::FetchPaymentStats.new(
              config:{
                loan: @loans,
                amount: @loans.total_balance,
                data_paid: @data[:date_resigned]
              }
              ).execute!

            loan_data = @loans.data.with_indifferent_access
            loan_data[:is_tapal] = true
            @account_transaction = AccountTransaction.new(
              subsidiary_id: @loans.id,
              subsidiary_type: "Loan",
              amount: @loans.total_balance.to_f,
              transaction_type: "loan_payment",
              transacted_at: @data[:date_resigned],
              status: "approved"
              
            )

            @amort_data = {
              amort_entries:[],
              total_interest_balance: 0.0,
              total_principal_balance: 0.0,
              amount_due: 0.0,
              particular:@data[:accounting_entry][:particular],
              approved_by:@user.full_name

            }

            @amort_data[:total_interest_paid]  = payment_stats[:interest_paid]
            @amort_data[:total_principal_paid] = payment_stats[:principal_paid]
            @amort_data[:amount_due]              = payment_stats[:amount_due]
            @amort_data[:amort_entries]           = payment_stats[:amort_entries]


            @account_transaction.data = @amort_data
            @account_transaction.save!

            @amort_data[:amort_entries].each do |ae|
              amort = AmortizationScheduleEntry.find(ae[:id])

              principal_paid = amort.principal_paid
              interest_paid  = amort.interest_paid

              principal_balance = amort.principal_balance
              interest_balance  = amort.interest_balance

              is_paid = amort.is_paid

              data = amort.data.try(:with_indifferent_access)

              if data.blank?
                data = {
                  payments: []
                }
              end

              data[:payments] <<{
                payment_id: @account_transaction.id,
                payment_date: @data[:date_resigned],
                principal_paid: ae[:principal_paid],
                interest_paid: ae[:interest_paid]
              }

              principal_paid  += ae[:principal_paid].try(:to_f).round(2)
              interest_paid   += ae[:interest_paid].try(:to_f).round(2)

              principal_balance = (amort.principal - principal_paid).round(2)
              interest_balance = (amort.interest - interest_paid).round(2)

              if principal_balance == 0.00 && interest_balance == 0.00
                is_paid = true
              end

              amort.principal_paid      = principal_paid
              amort.interest_paid       = interest_paid
              amort.principal_balance   = principal_balance
              amort.interest_balance    = interest_balance
              amort.is_paid             = is_paid
              amort.data                = data

              amort.save!             
            end

            update_amort = AmortizationScheduleEntry.where(loan_id: @loans.id).order("due_data DESC")
            @loans.principal_paid = update_amort.sum(:principal_paid).round(2)
            @loans.interest_paid  = update_amort.sum(:interest_paid).round(2)

            @loans.principal_balance  = (@loans.principal - @loans.principal_paid).round(2)
            @loans.interest_balance   = (@loans.interest - @loans.interest_paid).round(2)

            max_active_date = @loans.max_active_date

            if max_active_date.blank?
              max_active_date = update_amort.first.due_date
            end

            if @data[:date_resigned].to_date > max_active_date
              max_active_date = @data[:date_resigned].to_date
            end

            @loans.save!

            if @loans.principal_balance == 0.00 and @loans.interest_balance = 0.00
              @loans.update!(
                date_completed: @data[:date_resigned].to_date,
                status: "paid",
                max_active_date: @data[:date_resigned].to_date
                )
            elsif
                @loans.update!(status:"paid")
            end
            @account_transaction

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
