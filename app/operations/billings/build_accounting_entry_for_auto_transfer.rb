module Billings
  class BuildAccountingEntryForAutoTransfer
    def initialize(config:)
      @config = config
      @member_account = MemberAccount.find(config[:member_account_id])
      @branch = Branch.find(@member_account.branch_id)
      #@data   = @config[:data]
      @user   = @config[:user]
      @amount = config[:amount]
      @book         = "JVB"
      @prepared_by  = @user.full_name
      @particular   = "TO RECORD TRANSFER OF CBU FOR PAYMENT OF ADDITIONAL SHARE CAPITAL - #{@member_account.member.full_name} "

      @current_date = ::Utils::GetCurrentDate.new(
                        config: {
                          branch: @branch
                        }
                      ).execute!

      #@accounting_code_patronage_refund                       = AccountingCode.find(Settings.patronage_refund.accounting_code_patronage_refund_payable)
      @accounting_code_cbu                       = AccountingCode.find("5091fee6-b2a2-40a0-a717-c53ab483ea43")
      #@accounting_code_due_to_members                         = AccountingCode.find(Settings.patronage_refund.accounting_code_due_to_members)
      #@accounting_code_deposits_on_share_capital_subscription = AccountingCode.find(Settings.patronage_refund.accounting_code_deposits_on_share_capital_subscription)
      @accounting_code_sc                       = AccountingCode.find("370f5e4f-e4c8-454e-90b2-17919cc5ef92")
      

      @accounting_entry_data  = {
        book: @book,
        date_prepared: @current_date.strftime("%B %d, %Y"),
        company_name: Settings.company_name,
        company_address: Settings.company_address,
        branch: @branch.to_s.upcase,
        prepared_by: @prepared_by,
        particular: @particular,
        debit_journal_entries: [],
        credit_journal_entries: [],
        journal_entries: [],
        branch_id: @branch.id,
        branch_name: @branch.name,
        status: "display",
        data: {
          or_number: "",
          ar_number: "",
          check_number: "",
          check_voucher_number: "",
          date_of_check: "",
          sub_reference_number: "",
          payee: ""
        }
      }
    end

    def execute!
      @accounting_entry_data[:debit_journal_entries]  = build_debit_journal_entries!
      @accounting_entry_data[:credit_journal_entries] = build_credit_journal_entries!

      # Build journal entries
      @accounting_entry_data[:debit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount]
        }
      end

      @accounting_entry_data[:credit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount]
        }
      end

      @accounting_entry_data
    end

    private

    def build_debit_journal_entries!
      journal_entries = []

      accounting_code = @accounting_code_cbu
      amount          = @amount

      journal_entries << {
        accounting_code_id: accounting_code.id,
        code: accounting_code.code,
        name: accounting_code.name,
        amount: amount
      }

      journal_entries
    end

    def build_credit_journal_entries!
      journal_entries = []

      accounting_code = @accounting_code_sc
      amount          = @amount

      journal_entries << {
        accounting_code_id: accounting_code.id,
        code: accounting_code.code,
        name: accounting_code.name,
        amount: amount
      }

      journal_entries
    end

    def default_particular
      @particular       
    end
  end
end
