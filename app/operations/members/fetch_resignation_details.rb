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

      @resignation_settings.cooperative_accounts.each do |s|
        member_account  = MemberAccount.where(
                            member_id: @member.id,
                            account_type: s.account_type,
                            account_subtype: s.account_subtype
                          ).first
        
        if member_account.present? and member_account.balance > 0
          @data[:equity_accounts] << {
            id: member_account.id,
            balance: member_account.balance,
            account_type: member_account.account_type,
            account_subtype: member_account.account_subtype
          }
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

      @resignation_settings.cooperative_accounts.each do |s|
        member_account  = MemberAccount.where(
                            member_id: @member.id,
                            account_type: s.account_type,
                            account_subtype: s.account_subtype
                          ).first

        if member_account.present? and member_account.balance > 0
          accounting_code = AccountingCode.find(s.debit_accounting_code_id)
          amount          = member_account.balance

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

      @resignation_settings.cooperative_accounts.each do |s|
        member_account  = MemberAccount.where(
                            member_id: @member.id,
                            account_type: s.account_type,
                            account_subtype: s.account_subtype
                          ).first

        if member_account.present? and member_account.balance > 0
          accounting_code = AccountingCode.find(s.credit_accounting_code_id)
          amount          = member_account.balance

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
  end
end
