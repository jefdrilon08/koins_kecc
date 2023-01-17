namespace :manual do
  task :deposit => :environment do
    dait_paid         = ENV['DATE_PAID'].to_date
    user_id           = ENV['USER_ID']
    member_account_id = ENV['MEMBER_ACCOUNT_ID']
    amount            = ENV['AMOUNT'].to_f.round(2)
    is_interest       = ENV['IS_INTEREST'].present? ? true : false
    transaction_type  = ENV['TRANSACTION_TYPE']

    member_account  = MemberAccount.find(member_account_id)
    member          = member_account.member
    user            = User.find(user_id)

    account_transaction = AccountTransaction.new(
                            subsidiary_id: member_account_id,
                            subsidiary_type: 'MemberAccount',
                            amount: amount,
                            transaction_type: transaction_type,
                            transacted_at: date_paid,
                            status: 'approved'
                          )

    data  = {
      is_withdraw_payment: false,
      is_fund_transfer: false,
      is_interest: is_interest,
      is_adjustment: false,
      is_for_exit_age: false,
      is_for_loan_payments: false,
      accounting_entry_reference_number: nil,
      beginning_balance: 0.00,
      ending_balance: 0.00
    }

    # Compute beginning and ending balance
    data[:beginning_balance]  = member_account.balance.round(2)
    data[:ending_balance]     = (data[:beginning_balance] + amount).round(2)

    # Update account balance
    new_balance = (member_account.balance + amount).round(2)
    member_account.update(
      balance: new_balance
    )

    account_transaction.data = data

    account_transaction.save!
  end

  task :list_of_writeoff => :environment do
    require 'csv'
    branch_id = ENV['BRANCH_ID']
      @data = DataStore.billing_for_writeoff.order(Arel.sql("meta->>'branch_id' ASC"))
        CSV.open("#{Rails.root}/tmp/writeoff.csv", "w",:write_headers=> true, :headers => ["MEMBER NAME" ,"BRANCH","WRITEOFF YEAR", "GK","RSA","MBS","PSA","SIF","TIME DEPOSIT","CLIP",
          "EQUITY VALUE","HIIP","LF","RF","POLICY LOAN","CBU","SHARE CAPITAL"] ) do |csv|
          
            @data.each do |b|
              @year =  b["meta"]["as_of"]
              @branch = b["meta"]["branch_name"]
              a_data = b["data"]

              a_data_rec= a_data.with_indifferent_access[:record]        
              a_data_rec.each do |rec|
                @member_name = Member.find(rec["member"]["id"]).full_name
                @member_account_savings = MemberAccount.where(member_id: rec["member"]["id"], account_type: "SAVINGS")
                @member_account_insurance = MemberAccount.where(member_id: rec["member"]["id"], account_type: "INSURANCE")
                @member_account_equity = MemberAccount.where(member_id: rec["member"]["id"], account_type: "EQUITY")

                if @member_account_savings.present?
                  @member_account_savings.each do |sav|
                    if sav[:account_subtype] == "Golden K"
                      @gk = sav[:balance].to_f
                    elsif sav[:account_subtype] == "K-IMPOK"
                      @kimpok = sav[:balance].to_f
                    elsif sav[:account_subtype] == "Maintaining Balance Savings"
                      @mbs = sav[:balance].to_f
                    elsif sav[:account_subtype] == "Personal Savings Account"
                      @psa = sav[:balance].to_f
                    elsif sav[:account_subtype] == "Savings Investment Fund"
                      @sif = sav[:balance].to_f
                    elsif sav[:account_subtype] == "Time Deposit"
                      @td = sav[:balance].to_f
                    end
                  end
                end
                
                if @member_account_insurance.present?
                  @member_account_insurance.each do |ins|
                    if ins[:account_subtype] == "Credit Life Insurance Plan"
                      @clip = ins[:balance].to_f
                    elsif ins[:account_subtype] == "Equity Value"
                      @ev = ins[:balance].to_f
                    elsif ins[:account_subtype] == "Hospital Income Insurance Plan"
                      @hip = ins[:balance].to_f
                    elsif ins[:account_subtype] == "Life Insurance Fund"
                      @lif = ins[:balance].to_f
                    elsif ins[:account_subtype] == "Policy Loan"
                      @pl = ins[:balance].to_f
                    elsif ins[:account_subtype] == "Retirement Fund"
                      @rf = ins[:balance].to_f
                    end
                  end
                end

                if @member_account_equity.present?
                  @member_account_equity.each do |eq|
                    if eq[:account_subtype] == "CBU"
                      @cbu = eq[:balance].to_f
                    elsif eq[:account_subtype] == "Share Capital"
                      @sc = eq[:balance].to_f
                    end
                  end
                end
                csv << [@member_name,@branch,@year,@gk,@kimpok,@mbs,@psa,@sif,@td,@clip,@ev,@hip,@lif,@rf,@pl,@cbu,@sc]
              end
            
         
          end
        end
  end
end
