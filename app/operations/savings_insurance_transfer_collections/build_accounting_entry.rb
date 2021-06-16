module SavingsInsuranceTransferCollections
  class BuildAccountingEntry
    def initialize(config:)
      @config = config
      @branch = @config[:branch]
      @data   = @config[:data]
      @user   = @config[:user]

      @book         = "JVB"
      @prepared_by  = @user.full_name

      @current_date = ::Utils::GetCurrentDate.new(
                        config: {
                          branch: @branch
                        }
                      ).execute!

      @savings_subtype                    = @data[:savings_subtype]
      @savings_withdrawal_accounting_code = AccountingCode.find(
                                              Settings.savings_insurance_transfer_accounting_codes.select{ |s|
                                                s.savings_type == @savings_subtype
                                              }.first.withdrawal_accounting_code_id
                                            )

      @insurance_subtype                  = @data[:insurance_subtype]
      @insurance_deposit_accounting_code  = AccountingCode.find(
                                              Settings.insurance_accounting_codes.select{ |s|
                                                s.insurance_type == @insurance_subtype
                                              }.first.deposit_accounting_code_id
                                            )

      @total_amount = @data[:records].inject(0){ |sum, hash| sum + hash[:amount] }.to_f.round(2)
      
      @particular   = default_particular

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
          code: j[:code],
          amount: j[:amount]
        }
      end

      @accounting_entry_data[:credit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          code: j[:code],
          amount: j[:amount]
        }
      end

      @accounting_entry_data
    end

    private

    def build_debit_journal_entries!
      journal_entries = []

      accounting_code = @savings_withdrawal_accounting_code
      amount          = @total_amount

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

      accounting_code = @insurance_deposit_accounting_code
      amount          = @total_amount

      journal_entries << {
        accounting_code_id: accounting_code.id,
        code: accounting_code.code,
        name: accounting_code.name,
        amount: amount
      }

      journal_entries
    end

    def default_particular
      if !@data[:records].nil?
        ids = []
        names = []
        
        @data[:records].each do |o|
          ids << o[:member][:id]
        end

        Member.where("id IN (?)", ids.uniq).each do |member|
         names << member.check_name
        end

        "TO RECORD WITHDRAWAL OF #{@branch.name} - #{@insurance_subtype.upcase} #{@current_date.strftime("%B %d, %Y")}, #{names.join(', ')} = #{@total_amount}"
      else
        "TO RECORD WITHDRAWAL OF #{@branch.name} - #{@insurance_subtype}"
      end

    end
  end
end
