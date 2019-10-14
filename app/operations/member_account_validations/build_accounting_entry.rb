module MemberAccountValidations
  class BuildAccountingEntry
    include ActionView::Helpers::NumberHelper

    def initialize(config:)
      @config                       = config

      @user                         = @config[:user]
      @member_account_validation    = @config[:member_account_validation]
      @is_remote                    = @config[:is_remote]
      @branch                       = @member_account_validation.branch
      
      if Settings.activate_microinsurance
        branch_id  = Settings.try(:defaults).try(:default_branch).try(:id)
        @branch = Branch.where(id: branch_id).first
      end

      @particular                   = build_particular

      @current_date = ::Utils::GetCurrentDate.new(
                        config: {
                          branch: @branch
                        }
                      ).execute!

      @book                         = 'JVB'
      @accounting_fund_id           = ""

      if Settings.activate_microinsurance
        @accounting_fund_id            = AccountingFund.where(name: "Mutual Benefit Fund").first.id
      end

      @members  = Member.where(id: @member_account_validation.member_account_validation_records.pluck(:member_id))

      @lif_member_accounts    = MemberAccount.where("account_type = ? AND account_subtype = ? AND member_accounts.member_id IN (?)", "INSURANCE", "Life Insurance Fund", @members.pluck(:id))
      @total_lif_balance      = @lif_member_accounts.sum(:balance)

      if @member_account_validation.pending? || @member_account_validation.for_approval? || @member_account_validation.for_validation? || @member_account_validation.cancelled?   
          @accounting_entry_data  = {
            book: @book,
            date_prepared: @current_date.strftime("%B %d, %Y"),
            company_name: Settings.company_name,
            company_address: Settings.company_address,
            branch: @branch.to_s.upcase,
            prepared_by: @user.full_name,
            particular: @particular,
            debit_journal_entries: [],
            credit_journal_entries: [],
            journal_entries: [],
            branch_id: @branch.id,
            branch_name: @branch.name,
            status: "display",
            accounting_fund_id: @accounting_fund_id,
            data: {
              or_number: "",
              ar_number: ""
            }
          }
      else
        raise "Invalid member account validation"
      end
    end

    def execute!
      @accounting_entry_data[:debit_journal_entries]  = build_debit_entries
      @accounting_entry_data[:credit_journal_entries] = build_credit_entries

      # Build journal entries
      @accounting_entry_data[:debit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount],
          code: j[:code]
        }
      end

      @accounting_entry_data[:credit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount],
          code: j[:code]
        }
      end

      @accounting_entry_data
    end

    private

    def build_particular
      branch = @member_account_validation.branch
      members_for_particular = []
      @member_account_validation.member_account_validation_records.each do |iavr|
        members_for_particular << iavr.member.full_name_formatted
      end

      particular = "Transfer of RF, Equity Value, Equity Interest and RF Interest to savings account of #{members_for_particular.join(', ')} - #{branch.name}"

      if Settings.activate_microinsurance
        particular = "Withdrawal of RF, LIFE, Equity Interest and RF Interest of #{members_for_particular.join(', ')} - #{branch.name}"
      end

      if !@member_account_validation.particular.nil?
        particular = @member_account_validation.particular
      end

      particular
    end

    def compute_rf_and_equity_interest
      journal_entries = []

      rf_amount    = @member_account_validation.member_account_validation_records.sum(:interest)
      equity_amount = @member_account_validation.member_account_validation_records.sum(:equity_interest)

      amount = rf_amount + equity_amount

      # TODO: Make this configurable
      if @is_remote
        dr_accounting_code = AccountingCode.find('1f305ae6-2b7b-4c72-89cf-470c1ca91781')
      
        if amount > 0
          journal_entries << {
            accounting_code_id: dr_accounting_code.id,
            code: dr_accounting_code.code,
            name: dr_accounting_code.name,
            amount: rf_amount
          }
        end
      else
        # RECEIVABLE FROM MBA
        dr_accounting_code = AccountingCode.find('5db5e14d-0fcb-45a7-b468-c4cefe1ad041')
        
        if amount > 0
          journal_entries << {
            accounting_code_id: dr_accounting_code.id,
            code: dr_accounting_code.code,
            name: dr_accounting_code.name,
            amount: amount
          }
        end
      end
      
      journal_entries
    end

    def compute_total_lif_and_equity_interest
      journal_entries = []

      # TODO: Config accounting code for total_lif_accounting_code
      if @is_remote
        total_lif_amount          = @member_account_validation.member_account_validation_records.sum(:lif_50_percent)
        equity_interest           = @member_account_validation.member_account_validation_records.sum(:equity_interest)
        amount                    = total_lif_amount + equity_interest
        total_lif_accounting_code = AccountingCode.find('da7a9fa2-6b75-48a3-83f9-4c40347ab405')
      else
        total_lif_amount          = @lif_member_accounts.sum(:balance)
        equity_interest           = @member_account_validation.member_account_validation_records.sum(:equity_interest)
        amount                    = total_lif_amount + equity_interest

        total_lif_accounting_code = AccountingCode.find('07e4ccfd-8fdf-4210-a068-1b66f9b6521f')
      end

      journal_entries << {
        accounting_code_id: total_lif_accounting_code.id,
        code: total_lif_accounting_code.code,
        name: total_lif_accounting_code.name,
        amount: amount
      }

      journal_entries
    end

    def compute_lif_advanced
      journal_entries = []

      amount          = @member_account_validation.member_account_validation_records.sum(:advance_lif)
      accounting_code = AccountingCode.find('87286b3b-7ca8-4ba4-a377-292a34c5e011')

      if amount > 0
        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          amount: amount
        }
      end

      journal_entries
    end

    def compute_rf_and_interest
      journal_entries = []

      # RF + Interest
      rf_and_interest_amount          = @member_account_validation.member_account_validation_records.sum(:rf) + @member_account_validation.member_account_validation_records.sum(:advance_rf) + @member_account_validation.member_account_validation_records.sum(:interest)

      if @is_remote
        rf_and_interest_accounting_code = AccountingCode.find('01d46c5f-12a1-428d-ad4f-5ad7bc798b6b')
      else
        rf_and_interest_accounting_code = AccountingCode.find('714153eb-0a0b-4127-9e62-2643f10a6d96')
      end

      journal_entries << {
        accounting_code_id: rf_and_interest_accounting_code.id,
        code: rf_and_interest_accounting_code.code,
        name: rf_and_interest_accounting_code.name,
        amount: rf_and_interest_amount
      }

      journal_entries
    end

    # For KMBA Only
    def compute_equity_interest
      journal_entries = []

      amount    = @member_account_validation.member_account_validation_records.sum(:equity_interest)

      # TODO: Make this configurable
      dr_accounting_code = AccountingCode.find('aa11e0c4-c894-45f8-8be2-1715e23e223f')

      journal_entries << {
        accounting_code_id: dr_accounting_code.id,
        code: dr_accounting_code.code,
        name: dr_accounting_code.name,
        amount: amount
      }

      journal_entries
    end

    def build_debit_entries
      journal_entries = []

      compute_rf_and_equity_interest.each do |o|
        journal_entries << o
      end

      compute_total_lif_and_equity_interest.each do |o|
        journal_entries << o
      end

      if @is_remote
        compute_lif_advanced.each do |o|
          journal_entries << o
        end
      
        compute_equity_interest.each do |o|
          journal_entries << o
        end
      end

      compute_rf_and_interest.each do |o|
        journal_entries << o
      end
      
      journal_entries
    end

    def build_credit_entries
      journal_entries = []

      compute_interest_credit.each do |o|
        journal_entries << o
      end

      compute_lif_withdrawal_and_savings.each do |o|
        journal_entries << o
      end

      # COMMENT OUT
      compute_equity_interest_credit.each do |o|
        journal_entries << o
      end
    
      journal_entries
    end

    # Compute equity interest entry
    def compute_equity_interest_credit
      journal_entries = []

      if @is_remote
        cr_accounting_code  = AccountingCode.find('5024c74a-a6c7-491d-b557-3d49bfed31f9')
      else
        cr_accounting_code  = AccountingCode.find('07e4ccfd-8fdf-4210-a068-1b66f9b6521f')
      end

      amount    = @member_account_validation.member_account_validation_records.sum(:equity_interest)

      if amount > 0
        journal_entries << {
          accounting_code_id: cr_accounting_code.id,
          code: cr_accounting_code.code,
          name: cr_accounting_code.name,
          amount: amount
        }
      end

      journal_entries
    end

    def compute_interest_credit
      journal_entries = []

      if @is_remote
        cr_accounting_code  = AccountingCode.find('01d46c5f-12a1-428d-ad4f-5ad7bc798b6b')
      else
        cr_accounting_code  = AccountingCode.find('714153eb-0a0b-4127-9e62-2643f10a6d96')
      end

      amount    = @member_account_validation.member_account_validation_records.sum(:interest)

      if amount > 0
        journal_entries << {
          accounting_code_id: cr_accounting_code.id,
          code: cr_accounting_code.code,
          name: cr_accounting_code.name,
          amount: amount
        }
      end

      journal_entries
    end

    def compute_lif_withdrawal_and_savings
      journal_entries = []

      if !@is_remote
        lif_withdrawal_amount = @total_lif_balance
        lif_withdrawal_amount -= @member_account_validation.member_account_validation_records.sum(:advance_lif)
        # lif_withdrawal_amount -= @member_account_validation.member_account_validation_records.sum(:lif_50_percent)
        
        if Settings.activate_microloans
          lif_withdrawal_accounting_code = AccountingCode.find('819d6e6a-9391-4990-92e0-459ea53821fc')

          journal_entries << {
            accounting_code_id: lif_withdrawal_accounting_code.id,
            code: lif_withdrawal_accounting_code.code,
            name: lif_withdrawal_accounting_code.name,
            amount: lif_withdrawal_amount / 2
          }
        end
      end

      # WIP: Savings = RF + Interest + Advanced Payment + 50%
      savings_amount          = 0.00

      if @is_remote
        savings_accounting_code = AccountingCode.find('905c35b2-2388-4458-8de7-60636e10952f')
      else
        savings_accounting_code = AccountingCode.find('b7c23e58-e44e-46ae-a3ec-b5081d6eed32')
      end

      savings_amount += @member_account_validation.member_account_validation_records.sum(:rf)
      savings_amount += @member_account_validation.member_account_validation_records.sum(:advance_rf)
      savings_amount += @member_account_validation.member_account_validation_records.sum(:interest)
      savings_amount += @member_account_validation.member_account_validation_records.sum(:advance_lif)
      savings_amount += @member_account_validation.member_account_validation_records.sum(:lif_50_percent)
      
      #COMMENT OUT
      savings_amount += @member_account_validation.member_account_validation_records.sum(:equity_interest)
      # savings_amount += @total_lif_balance / 2

      journal_entries << {
            accounting_code_id: savings_accounting_code.id,
            code: savings_accounting_code.code,
            name: savings_accounting_code.name,
            amount: savings_amount
          }

      journal_entries
    end
  end
end
