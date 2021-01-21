module Members
  class FetchResignationDetails
    def initialize(config:)
      @config = config

      @member = @config[:member]
      @user   = @config[:user]

      @branch = @member.branch
      @center = @member.center

      # Accounting entry details
      @book           = @config[:book] || "JVB"
      @date_prepared  = @config[:date_prepared] || Date.today

      @resignation_settings     = Settings.resignation
      @member_resignation_types = Settings.member_resignation_types

      if @resignation_settings.blank?
        raise "Config: resignation_settings not found"
      end

      if @member_resignation_types.blank?
        raise "Config: member_resignation_types not found"
      end

      @settings_savings_account = @resignation_settings.savings_account

      if @settings_savings_account.blank?
        raise "Config: resignation.savings_account not found"
      end

      @savings_account  = MemberAccount.where(
                            member_id: @member.id,
                            account_type: @settings_savings_account.account_type,
                            account_subtype: @settings_savings_account.account_subtype
                          ).first

      if @savings_account.blank?
        raise "Savings account for account type #{@settings_savings_account.account_type} and account subtype #{@settings_savings_account.account_subtype} not found"
      end

      @settings_equity_accounts = Settings.resignation.equity_accounts

      if @settings_equity_accounts.blank?
        raise "settings_equity_accounts not found"
      end

      @closing_fee                  = @resignation_settings.closing_fee
      @number_of_years              = @resignation_settings.number_of_years
      @closing_fee_accounting_code  = AccountingCode.find(@resignation_settings.closing_fee_accounting_code_id)
      @deposits_accounting_code     = AccountingCode.find(@resignation_settings.deposits_accounting_code_id)

      @savings_credit_accounting_code = AccountingCode.find(@settings_savings_account.credit_accounting_code_id)

      @data = {
        member: {
          id: @member.id,
          first_name: @member.first_name,
          middle_name: @member.middle_name,
          last_name: @member.last_name
        },
        branch: {
          id: @member.branch.id,
          name: @member.branch.name
        },
        center: {
          id: @member.center.id,
          name: @member.center.name
        },
        equity_accounts: [],
        date_resigned: Date.today,
        particular: default_particular,
        member_resignation_type: {
          name: @member_resignation_types.first.name,
          particular: {
            code: @member_resignation_types.first.particulars.first.code,
            name: @member_resignation_types.first.particulars.first.name
          }
        }
      }

    end

    def execute!
      @member_accounts  = [] 

      @settings_equity_accounts.each do |s_eq|
        member_account  = MemberAccount.where(
                            member_id: @member.id,
                            account_type: s_eq.account_type,
                            account_subtype: s_eq.account_subtype
                          ).first
        if member_account.present? and member_account.balance > 0
          @data[:equity_accounts] << {
            id: member_account.id,
            balance: member_account.balance,
            account_type: member_account.account_type,
            account_subtype: member_account.account_subtype
          }

            #for 4yrs 
            f_eq= AccountTransaction.where(subsidiary_id: member_account.id).first
            date_closing = f_eq.transacted_at + @number_of_years.years
            dt = Date.today
            if date_closing <= dt
              @closing_fee = @resignation_settings.closing_fee
            else
               @closing_fee = 0
            end
            #end 

        end
      end

      @data[:accounting_entry]  = build_accounting_entry!

      @data
    end

    private

    def default_particular
      "Resignation for member #{@member.full_name}"
    end

    def build_accounting_entry!
      accounting_entry_data = {
        book: @book,
        date_prepared: @date_prepared,
        company_name: Settings.company_name,
        company_address: Settings.company_address,
        branch: @branch.to_s.upcase,
        prepared_by: @user.full_name,
        particular: default_particular,
        debit_journal_entries: [],
        credit_journal_entries: [],
        journal_entries: [],
        branch_id: @branch.id,
        branch_name: @branch.name,
        status: "display",
        data: {
          or_number: "",
          ar_number: ""
        }
      }

      accounting_entry_data[:debit_journal_entries]   = build_debit_journal_entries!
      accounting_entry_data[:credit_journal_entries]  = build_credit_journal_entries!

      # Build journal entries
      accounting_entry_data[:debit_journal_entries].each do |j|
        accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount]
        }
      end

      accounting_entry_data[:credit_journal_entries].each do |j|
        accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount]
        }
      end

      accounting_entry_data
    end

    def build_debit_journal_entries!
      journal_entries = []

      @settings_equity_accounts.each do |s_eq|
        equity_account  = MemberAccount.where(
                            member_id: @member.id,
                            account_type: s_eq.account_type,
                            account_subtype: s_eq.account_subtype
                          ).first

        if equity_account.present? and equity_account.balance > 0
          amount          = equity_account.balance
          accounting_code = AccountingCode.find(s_eq.debit_accounting_code_id)

          journal_entries << {
            accounting_code_id: accounting_code.id,
            code: accounting_code.code,
            name: accounting_code.name,
            amount: amount
          }
        end
      end

      journal_entries
    end

    def build_credit_journal_entries!
      journal_entries = []

      # Closing fee
      if @closing_fee  > 0
      journal_entries << {
        accounting_code_id: @closing_fee_accounting_code.id,
        code: @closing_fee_accounting_code.code,
        name: @closing_fee_accounting_code.name,
        amount: @closing_fee
      }
      end

      # Deposit amount
      deposit_amount  = 0.00

      @settings_equity_accounts.each do |s_eq|
        equity_account  = MemberAccount.where(
                            member_id: @member.id,
                            account_type: s_eq.account_type,
                            account_subtype: s_eq.account_subtype
                          ).first

        if equity_account.present? and equity_account.balance > 0
          deposit_amount += equity_account.balance
        end
      end

      deposit_amount  = deposit_amount - @closing_fee

      if deposit_amount > 0
        journal_entries << {
          accounting_code_id: @deposits_accounting_code.id,
          code: @deposits_accounting_code.code,
          name: @deposits_accounting_code.name,
          amount: deposit_amount
        }
      end

      # Store deposit amount
      @data[:deposit] = {
        amount: deposit_amount,
        member_account_id: @savings_account.id
      }

      journal_entries
    end
  end
end
