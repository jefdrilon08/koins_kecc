module SavingsInsuranceTransferCollections
  class BuildAccountingEntry
    def initialize(config:)
      @config = config
      @branch = @config[:branch]
      @data   = @config[:data]
      @user   = @config[:user]
      @payment_subtype = @data["payment_subtype"]
      @insurance_subtype = @data["insurance_subtype"]
      @accounting_fund_gen_fund = "8a512ccd-20a8-457f-a7ac-ab6bd76bb814"
      @accounting_fund_opt_fund = "d99d1c46-d426-41fa-ba95-b57b6ca27d1d"
      @or_number = @data["or_number"]
      @ar_number = @data["ar_number"]

      # raise @or_number.inspect

      @book         = "JVB"
      @book1        = "CRB"
      @prepared_by  = @user.full_name

      if Settings.activate_microinsurance
        branch_id  = Settings.try(:defaults).try(:default_branch).try(:id)
        @branch = Branch.where(id: branch_id).first
      end
      
      @current_date = ::Utils::GetCurrentDate.new(
                        config: {
                          branch: @branch
                        }
                      ).execute!
      if !Settings.activate_microinsurance
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
      else 
        if @payment_subtype == "OTHER-BANK" && @insurance_subtype != "Hospital Income Insurance Plan"
          @savings_withdrawal_accounting_code = AccountingCode.find(
                                                  Settings.savings_insurance_transfer_accounting_codes.select{ |s|
                                                    s.payment_type == "OTHER-BANK"
                                                  }.first.withdrawal_accounting_code_id
                                                )

          @insurance_subtype                  = @data[:insurance_subtype]
          @insurance_deposit_accounting_code  = AccountingCode.find(
                                                  Settings.insurance_accounting_codes.select{ |s|
                                                    s.insurance_type == @insurance_subtype
                                                  }.first.deposit_accounting_code_id
                                                )
        elsif @payment_subtype == "OTHER-BANK" && @insurance_subtype == "Hospital Income Insurance Plan"
          @savings_withdrawal_accounting_code = AccountingCode.find(
                                                  Settings.savings_insurance_transfer_accounting_codes.select{ |s|
                                                    s.payment_type == "OTHER-BANK"
                                                  }.first.hiip_withdrawal_accounting_code_id
                                                )

          @insurance_subtype                  = @data[:insurance_subtype]
          @insurance_deposit_accounting_code  = AccountingCode.find(
                                                  Settings.insurance_accounting_codes.select{ |s|
                                                    s.insurance_type == @insurance_subtype
                                                  }.first.deposit_accounting_code_id
                                                )
        elsif @payment_subtype == "CASH" && @insurance_subtype == "Hospital Income Insurance Plan"
          @savings_withdrawal_accounting_code = AccountingCode.find(
                                                  Settings.savings_insurance_transfer_accounting_codes.select{ |s|
                                                    s.payment_type == "CASH"
                                                  }.first.hiip_withdrawal_accounting_code_id
                                                )

          @insurance_subtype                  = @data[:insurance_subtype]
          @insurance_deposit_accounting_code  = AccountingCode.find(
                                                  Settings.insurance_accounting_codes.select{ |s|
                                                    s.insurance_type == @insurance_subtype
                                                  }.first.deposit_accounting_code_id
                                                )
        elsif @payment_subtype == "RECEIVABLE" && @insurance_subtype == "Credit Life Insurance Plan"
          @savings_withdrawal_accounting_code = AccountingCode.find(
                                                  Settings.savings_insurance_transfer_accounting_codes.select{ |s|
                                                    s.payment_type == "RECEIVABLE"
                                                  }.first.withdrawal_accounting_code_id
                                                )

          @insurance_subtype                  = @data[:insurance_subtype]
          @insurance_deposit_accounting_code  = AccountingCode.find(
                                                  Settings.insurance_accounting_codes.select{ |s|
                                                    s.insurance_type == @insurance_subtype
                                                  }.first.deposit_accounting_code_id
                                                )
        elsif @payment_subtype == "RECEIVABLE" && @insurance_subtype == "K-BENTE"
          @savings_withdrawal_accounting_code = AccountingCode.find(
                                                  Settings.savings_insurance_transfer_accounting_codes.select{ |s|
                                                    s.payment_type == "RECEIVABLE"
                                                  }.first.kbente_withdrawal_accounting_code_id
                                                )

          @insurance_subtype                  = @data[:insurance_subtype]
          @insurance_deposit_accounting_code  = AccountingCode.find(
                                                  Settings.insurance_accounting_codes.select{ |s|
                                                    s.insurance_type == @insurance_subtype
                                                  }.first.deposit_accounting_code_id
                                                )
        elsif @payment_subtype == "RECEIVABLE" && @insurance_subtype == "K-KALINGA"
          @savings_withdrawal_accounting_code = AccountingCode.find(
                                                  Settings.savings_insurance_transfer_accounting_codes.select{ |s|
                                                    s.payment_type == "RECEIVABLE"
                                                  }.first.kkalinga_withdrawal_accounting_code_id
                                                )

          @insurance_subtype                  = @data[:insurance_subtype]
          @insurance_deposit_accounting_code  = AccountingCode.find(
                                                  Settings.insurance_accounting_codes.select{ |s|
                                                    s.insurance_type == @insurance_subtype
                                                  }.first.deposit_accounting_code_id
                                                )
        else
          @payment_subtypes                   = @data[:payment_subtype]
          @savings_withdrawal_accounting_code = AccountingCode.find(
                                                  Settings.savings_insurance_transfer_accounting_codes.select{ |s|
                                                    s.payment_type == "CASH"
                                                  }.first.withdrawal_accounting_code_id
                                                )

          @insurance_subtype                  = @data[:insurance_subtype]
          @insurance_deposit_accounting_code  = AccountingCode.find(
                                                  Settings.insurance_accounting_codes.select{ |s|
                                                    s.insurance_type == @insurance_subtype
                                                  }.first.deposit_accounting_code_id
                                                )
        end
      end
      @total_amount = @data[:records].inject(0){ |sum, hash| sum + hash[:amount] }.to_f.round(2)
      
      @particular   = default_particular
      if Settings.activate_microinsurance
        if @payment_subtype == "CASH" && @insurance_subtype == "K-KALINGA"
          @accounting_entry_data  = {
            book: @book1,
            accounting_fund_id: @accounting_fund_gen_fund,
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
              or_number: @or_number,
              ar_number: @ar_number,
              check_number: "",
              check_voucher_number: "",
              date_of_check: "",
              sub_reference_number: "",
              payee: ""
            }
          }

        elsif @payment_subtype == "CASH" && @insurance_subtype == "K-BENTE"
          @accounting_entry_data  = {
            book: @book1,
            accounting_fund_id: @accounting_fund_gen_fund,
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
              or_number: @or_number,
              ar_number: @ar_number,
              check_number: "",
              check_voucher_number: "",
              date_of_check: "",
              sub_reference_number: "",
              payee: ""
            }
          }

        elsif @payment_subtype == "CASH" && @insurance_subtype == "Hospital Income Insurance Plan"
          @accounting_entry_data  = {
            book: @book1,
            accounting_fund_id: @accounting_fund_opt_fund,
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
              or_number: @or_number,
              ar_number: @ar_number,
              check_number: "",
              check_voucher_number: "",
              date_of_check: "",
              sub_reference_number: "",
              payee: ""
            }
          }

        elsif @payment_subtype == "CASH"
          @accounting_entry_data  = {
            book: @book1,
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
              or_number: @or_number,
              ar_number: @ar_number,
              check_number: "",
              check_voucher_number: "",
              date_of_check: "",
              sub_reference_number: "",
              payee: ""
            }
          }

        elsif @payment_subtype == "OTHER-BANK" && @insurance_subtype == "Hospital Income Insurance Plan"          
          @accounting_entry_data  = {
            book: @book,
            accounting_fund_id: @accounting_fund_opt_fund,
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
              or_number: @or_number,
              ar_number: @ar_number,
              check_number: "",
              check_voucher_number: "",
              date_of_check: "",
              sub_reference_number: "",
              payee: ""
            }
          }
        
        elsif @payment_subtype == "OTHER-BANK" && @insurance_subtype == "K-KALINGA"          
          @accounting_entry_data  = {
            book: @book,
            accounting_fund_id: @accounting_fund_gen_fund,
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
              or_number: @or_number,
              ar_number: @ar_number,
              check_number: "",
              check_voucher_number: "",
              date_of_check: "",
              sub_reference_number: "",
              payee: ""
            }
          }
        
        elsif @payment_subtype == "OTHER-BANK" && @insurance_subtype == "K-BENTE"          
          @accounting_entry_data  = {
            book: @book,
            accounting_fund_id: @accounting_fund_gen_fund,
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
              or_number: @or_number,
              ar_number: @ar_number,
              check_number: "",
              check_voucher_number: "",
              date_of_check: "",
              sub_reference_number: "",
              payee: ""
            }
          }

        elsif @payment_subtype == "RECEIVABLE" && @insurance_subtype == "K-BENTE"          
          @accounting_entry_data  = {
            book: @book,
            accounting_fund_id: @accounting_fund_gen_fund,
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
              or_number: @or_number,
              ar_number: @ar_number,
              check_number: "",
              check_voucher_number: "",
              date_of_check: "",
              sub_reference_number: "",
              payee: ""
            }
          }

        elsif @payment_subtype == "RECEIVABLE" && @insurance_subtype == "K-KALINGA"          
          @accounting_entry_data  = {
            book: @book,
            accounting_fund_id: @accounting_fund_gen_fund,
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
              or_number: @or_number,
              ar_number: @ar_number,
              check_number: "",
              check_voucher_number: "",
              date_of_check: "",
              sub_reference_number: "",
              payee: ""
            }
          }

        else        
          @accounting_entry_data  = {
            book: @book,
            accounting_fund_id: @accounting_fund_gen_fund,
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
              or_number: @or_number,
              ar_number: @ar_number,
              check_number: "",
              check_voucher_number: "",
              date_of_check: "",
              sub_reference_number: "",
              payee: ""
            }
          }
        end
        
      else
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

        if !Settings.activate_microinsurance
          "TO RECORD WITHDRAWAL OF #{@branch.name} - #{@insurance_subtype.upcase} #{@current_date.strftime("%B %d, %Y")}, #{names.join(', ')} = #{@total_amount}"
        else
          "TO RECORD PAYMENT OF #{@branch.name} - #{@insurance_subtype.upcase} #{@current_date.strftime("%B %d, %Y")}, #{names.join(', ')} = #{@total_amount}"
        end
      else
        if !Settings.activate_microinsurance
          "TO RECORD WITHDRAWAL OF #{@branch.name} - #{@insurance_subtype}"
        else
          "TO RECORD PAYMENT OF #{@branch.name} - #{@insurance_subtype}"
        end
      end

    end
  end
end