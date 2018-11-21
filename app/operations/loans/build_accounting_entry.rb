module Loans
  class BuildAccountingEntry
    def initialize(config:)
      @config       = config
      @member       = @config[:member]
      @branch       = @member.branch
      @loan_product = @config[:loan_product]
      @amount       = @config[:amount].to_f.round(2)
      @current_date = @config[:current_date] || Date.today
      @book         = @config[:book] || "CDB"

      @user = @config[:user]

      if @user.present?
        @prepared_by  = @user.full_name
      else
        @prepared_by  = "SYSTEM"
      end

      @particular = @config[:particular] || default_particular

      @num_installments = @config[:num_installments]
      @term             = @config[:term]
      @amount_released  = @amount

      @accounting_entry_data  = {
        book: @book,
        date_prepared: @current_date.strftime("%B %d, %Y"),
        company_name: Settings.company_name,
        company_address: Settings.company_address,
        branch: @branch.to_s.upcase,
        prepared_by: @prepared_by,
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

      @settings = nil

      Settings.loan_products.each do |s|
        if s.loan_product_id == @loan_product.id
          @settings = s
        end
      end

      if @settings.blank?
        raise "Settings not foud for loan product #{@loan_product.id}: #{@loan_product.name}"
      end

      @receivable_accounting_code = AccountingCode.find(@settings.receivable_accounting_code_id)
    end

    def execute!
      @accounting_entry_data[:credit_journal_entries] = build_credit_journal_entries!
      @accounting_entry_data[:debit_journal_entries]  = build_debit_journal_entries!

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

      # Amount released
      accounting_code = AccountingCode.find(@settings.receivable_accounting_code_id)
      amount          = @amount_released
      name            = accounting_code.name
      code            = accounting_code.code

      journal_entries << {
        accounting_code_id: accounting_code.id,
        code: code,
        name: name,
        amount: amount
      }

      # additional_amount_branch_term_map
      @settings.deductions.each do |s_deduction|
        deduction_type  = s_deduction.deduction_type
        if deduction_type == "additional_amount_branch_term_map"
          s_deduction.meta.branches.each do |s_b|
            accounting_code     = AccountingCode.find(s_deduction.accounting_code_id)
            amount              = s_deduction.amount
            name                = accounting_code.name
            code                = accounting_code.code

            if @term == "weekly"
              s_deduction.meta.term_map.weekly.each do |s|
                if s.num_installments == @num_installments
                  amount  = (s.ratio * @amount).round(2)
                end
              end
            elsif @term == "monthly"
              s_deduction.meta.term_map.monthly.each do |s|
                if s.num_installments == @num_installments
                  amount  = (s.ratio * @amount).round(2)
                end
              end
            elsif @term == "semi-monthly"
              s_deduction.meta.term_map.semi_monthly.each do |s|
                if s.num_installments == @num_installments
                  amount  = (s.ratio * @amount).round(2)
                end
              end
            else
              raise "Invalid term: #{@term}"
            end

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount
            }
          end
        end
      end

      journal_entries
    end

    def build_credit_journal_entries!
      # compute amount released by deducting from @amount
      temp_amount = @amount

      journal_entries = []

      @settings.deductions.each do |s_deduction|
        deduction_type  = s_deduction.deduction_type

        if deduction_type == "straight_one_time"
          if @member.loans.active_or_paid.count == 0
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            amount          = s_deduction.amount
            name            = accounting_code.name
            code            = accounting_code.code

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount
            }

            temp_amount -= amount
          end
        elsif deduction_type == "membership_fee"
          if s_deduction.membership_type == "Cooperative" and @member.status == "pending"
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            amount          = s_deduction.amount
            name            = accounting_code.name
            code            = accounting_code.code

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount
            }

            temp_amount -= amount
          elsif s_deduction.membership_type == "Insurance" and @member.status == "pending"
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            amount          = s_deduction.amount
            name            = accounting_code.name
            code            = accounting_code.code

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount
            }

            temp_amount -= amount
          end
        elsif deduction_type == "additional_amount_branch_term_map"
          s_deduction.meta.branches.each do |s_b|
            if s_b.branch_id == @branch.id
              accounting_code     = AccountingCode.where(id: s_b.complimentary_accounting_code_id).first
              amount              = s_deduction.amount
              name                = accounting_code.name
              code                = accounting_code.code

              if @term == "weekly"
                s_deduction.meta.term_map.weekly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * @amount).round(2)
                  end
                end
              elsif @term == "monthly"
                s_deduction.meta.term_map.monthly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * @amount).round(2)
                  end
                end
              elsif @term == "semi-monthly"
                s_deduction.meta.term_map.semi_monthly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * @amount).round(2)
                  end
                end
              else
                raise "Invalid term: #{@term}"
              end

              journal_entries << {
                accounting_code_id: accounting_code.id,
                code: code,
                name: name,
                amount: amount
              }

              temp_amount -= amount
            end
          end
        elsif deduction_type == "member_type_deduction_ratio"
          target_member_type  = s_deduction.meta.member_type
          accounting_code     = AccountingCode.find(s_deduction.accounting_code_id)
          amount              = s_deduction.amount
          name                = accounting_code.name
          code                = accounting_code.code

          if @member.member_type  == target_member_type
            if @term == "weekly"
              s_deduction.meta.term_map.weekly.each do |s|
                if s.num_installments == @num_installments
                  amount  = (s.ratio * @amount).round(2)
                end
              end
            elsif @term == "monthly"
              s_deduction.meta.term_map.monthly.each do |s|
                if s.num_installments == @num_installments
                  amount  = (s.ratio * @amount).round(2)
                end
              end
            elsif @term == "semi-monthly"
              s_deduction.meta.term_map.semi_monthly.each do |s|
                if s.num_installments == @num_installments
                  amount  = (s.ratio * @amount).round(2)
                end
              end
            else
              raise "Invalid term: #{@term}"
            end

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount
            }

            temp_amount -= amount
          end
        elsif deduction_type == "deposit"
          if s_deduction.meta.algo == "term_multiplier_for_second_cycle_onwards"
            offset          = s_deduction.meta.offset
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            name            = accounting_code.name
            code            = accounting_code.code
            amount          = 0.00
            val             = s_deduction.meta.value

            multiplier  = @num_installments

            if @member.loans.paid.where(loan_product_id: @loan_product.id).count >= 1
              if @term == "weekly"
              elsif @term == "monthly"
                multiplier  = (multiplier * 4.3333333).ceil.to_i
              elsif @term == "semi-monthly"
                # weird unique rule for 12 semi-monthly
                if @num_installments ==  12
                  multiplier  = 12.5 * 2
                elsif @num_installments == 6
                  multiplier  = 15
                else
                  multiplier  = multiplier * 2
                end
              else
                raise "Invalid term #{@term}"
              end

              amount  = s_deduction.amount * (multiplier + offset)
            else
              amount  = s_deduction.amount
            end

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount
            }

            temp_amount -= amount
          else
            raise "Invalid deduction type algo #{s_deduction.meta.algo}"
          end
        end
      end

      # Update amount
      @amount_released  = temp_amount

      journal_entries
    end

    def default_particular
      "TODO: Changeme"
    end
  end
end
