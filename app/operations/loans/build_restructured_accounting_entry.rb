module Loans
  class BuildRestructuredAccountingEntry
    attr_accessor :total_debit

    def initialize(config:)
      @config       = config
      @loan         = @config[:loan]
      @member       = @config[:member]
      @branch       = @member.branch
      @loan_product = @config[:loan_product]
      @amount       = @config[:amount].to_f.round(2)
      @book         = @config[:book] || "JVB"
      @loan_data    = @loan.data.with_indifferent_access
      @voucher_data = @loan_data[:voucher]
      @active_loans = @config[:active_loans]

      @miscellaneous_offset = 0.00

      # Single amount for debit entry computed in build_credit_journal_entries!
      @total_debit = 0.00

      @current_date = ::Utils::GetCurrentDate.new(
                        config: {
                          branch: @branch
                        }
                      ).execute!

      @member       = @loan.member
      @member_data  = @member.data.with_indifferent_access

      # Setup loan cycle
      @member_data  = @loan.member.data.with_indifferent_access
      @loan_cycles  = @member_data[:loan_cycles] || []
    
      @entry_point_loan_cycle_count = @member.entry_point_loan_cycle_count

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

      # Main settings for this loan product
      @settings_loan_products = Settings.loan_products

      if @settings_loan_products.blank?
        raise "settings_loan_products not found"
      end

      # Actual loan product settings
      @settings = @settings_loan_products.select{ |s| 
                    s.loan_product_id == @loan_product.id and s.for_restructuring == true 
                  }.first

      if @settings.blank?
        raise "No settings found for loan_product #{@loan_product.id}"
      end

      # Primary for restructuring (initial deductions)
      @settings_primary = @settings.deductions.select{ |s| s.restructuring_primary == true }

      if @settings_primary.blank?
        raise "No primary restructuring settings found for loan_product #{@loan_product.id}"
      end

      # Secondary for application on top of primary
      @settings_secondary = @settings.deductions.select{ |s| s.restructuring_secondary == true }

      if @settings_secondary.blank?
        raise "No secondary restructuring settings found for loan_product #{@loan_product.id}"
      end

      # Offset for round off (only one)
      @settings_offset  = @settings.deductions.select{ |s| s.restructuring_offset == true }.first
      
      if @settings_offset.blank?
        raise "No offset settings found for loan_product #{@loan_product.id}"
      end

      # Offset for miscellaneous expense
      @settings_miscellaneous_accounting_code_id  = @settings.miscellaneous_accounting_code_id

      if @settings_miscellaneous_accounting_code_id.blank?
        raise "No miscellaneous offset settings found for loan_product #{@loan_product.id}"
      end

      # Branch related accounting code settings
      @settings_branch_accounting_codes = nil

      Settings.branch_accounting_codes.each do |o|
        if o.branch_id == @branch.id
          @settings_branch_accounting_codes = o
        end
      end

      if @settings_branch_accounting_codes.blank?
        raise "Settings not found for branch #{@branch.id}: #{@branch.name}. Please check production.yml"
      end

      # Insurance membership can be paid form loans. This is its settings
      @settings_insurance_membership

      Settings.memberships.each do |o|
        if o.type == "Insurance" and o.is_main == true
          @settings_insurance_membership = o
        end
      end

      if @settings_insurance_membership.blank?
        raise "Settings not found for insurance membership. Please check production.yml"
      end

      # Receivable accounting code
      @receivable_accounting_code = AccountingCode.find(@settings.receivable_accounting_code_id)
    end

    def execute!
      build_data!

      @accounting_entry_data[:credit_journal_entries] = build_credit_journal_entries!
      @accounting_entry_data[:debit_journal_entries]  = build_debit_journal_entries!

      # Build journal entries
      @accounting_entry_data[:debit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: "#{j[:code]} - #{j[:name]}",
          amount: j[:amount]
        }
      end

      @accounting_entry_data[:credit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: "#{j[:code]} - #{j[:name]}",
          amount: j[:amount]
        }
      end

      @accounting_entry_data
    end

    private

    def build_data!
      or_number         = @loan_data.fetch("or_number", "")
      bank_check_number = @voucher_data.fetch("bank_check_number", "")
      check_number      = @voucher_data.fetch("check_number", "")
      date_of_check     = @voucher_data.fetch("date_of_check", "")

      @accounting_entry_data[:data] = {
        or_number: or_number,
        ar_number: "",
        check_number: bank_check_number,
        check_voucher_number: check_number,
        date_of_check: date_of_check,
        sub_reference_number: "",
        payee: "#{@member.full_name}"
      }
    end

    def build_debit_journal_entries!
      journal_entries = []

      # Receivable
      accounting_code = AccountingCode.find(@settings.receivable_accounting_code_id)
      amount          = @total_debit
      name            = accounting_code.name
      code            = accounting_code.code

      journal_entries << {
        accounting_code_id: accounting_code.id,
        code: code,
        name: name,
        amount: amount
      }

      if @miscellaneous_offset < 0
        # Add miscellaneous expense to debit sidte
        accounting_code = AccountingCode.find(@settings_miscellaneous_accounting_code_id)
        code            = accounting_code.code
        name            = accounting_code.name
        amount          = @miscellaneous_offset.abs

        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: code,
          name: name,
          amount: amount
        }
      end

      journal_entries
    end

    def build_credit_journal_entries!
      journal_entries = []

      # Sum of all remaining balances of active_loans
      @active_loans.each do |active_loan|
        settings = Settings.loan_products.select{ |o| o.loan_product_id == active_loan.loan_product_id }.first

        receivable_accounting_code          = AccountingCode.find(settings.receivable_accounting_code_id)
        interest_receivable_accounting_code = AccountingCode.find(settings.interest_receivable_accounting_code_id)

        loans_receivable    = active_loan.principal_balance.round(2)
        #interest_receivable = active_loan.interest_balance.round(2)
        interest_receivable = active_loan.amortization_schedule_entries.where(
                                "due_date <= ? AND is_paid IS NULL",
                                @current_date
                              ).sum(:interest_balance).round(2)

        @total_debit += loans_receivable
        @total_debit += interest_receivable

        if loans_receivable > 0
          journal_entries << {
            accounting_code_id: receivable_accounting_code.id,
            amount: loans_receivable,
            name: receivable_accounting_code.name,
            code: receivable_accounting_code.code
          }
        end

        if interest_receivable > 0
         journal_entries << {
            accounting_code_id: interest_receivable_accounting_code.id,
            amount: interest_receivable,
            name: interest_receivable_accounting_code.name,
            code: interest_receivable_accounting_code.code
          }
        end
      end

      # Deductions: Only support member_type_deduction_ratio
      # compute amount released by deducting from @amount
      temp_amount = @amount
      @settings_primary.each do |s_deduction|
        deduction_type  = s_deduction.deduction_type

        if deduction_type == "straight_one_time"
          #if @member.loans.active_or_paid.count == 0
          if @loan_cycles.size == 0
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            amount          = s_deduction.amount.round(2)
            name            = accounting_code.name
            code            = accounting_code.code

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount
            }

            temp_amount -= amount
            @total_debit += amount
          end
        elsif deduction_type == "membership_fee"
          if s_deduction.membership_type == "Cooperative" and @member.status == "pending"
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            amount          = s_deduction.amount.round(2)
            name            = accounting_code.name
            code            = accounting_code.code

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount
            }

            temp_amount -= amount
            @total_debit += amount
          elsif s_deduction.membership_type == "Insurance" and @member.insurance_status == "pending"
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            amount          = s_deduction.amount.round(2)
            name            = accounting_code.name
            code            = accounting_code.code

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount
            }

            temp_amount -= amount
            @total_debit += amount
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

              amount = amount.round(2)

              journal_entries << {
                accounting_code_id: accounting_code.id,
                code: code,
                name: name,
                amount: amount
              }

              #temp_amount -= amount
              @total_debit += amount
            end
          end
        elsif deduction_type == "member_type_deduction_ratio"
          target_member_type  = s_deduction.meta.member_type
          accounting_code     = AccountingCode.find(s_deduction.accounting_code_id)
          amount              = s_deduction.amount
          name                = accounting_code.name
          code                = accounting_code.code

          # Special: business_permit_available
          if s_deduction.business_permit_available.present? and s_deduction.business_permit_available == true and @loan_data[:business_permit_available].present? and @loan_data[:business_permit_available].to_s == "true"
            amount  = (s_deduction.business_permit_amount).round(2)

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount
            }

            temp_amount -= amount
            @total_debit += amount
          elsif s_deduction.for_primary_loan.present? and s_deduction.for_primary_loan == true 
            primary_loan_id = s_deduction.primary_loan_id
            loan_count = Loan.where("member_id = ? and status = ? and loan_product_id IN (?)", @member.id,"active", primary_loan_id).count
            if loan_count == 0
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
              @total_debit += amount
            end
          else
            if @member.member_type == "GK"
              if  s_deduction.use_for_special_loan_fund == "true"
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
                @total_debit += amount
              end
            else
              if  s_deduction.skip_for_special_loan_fund == "true"
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
                @total_debit += amount
              end
            end
          end
        elsif deduction_type == "deposit"
          if s_deduction.meta.algo == "term_multiplier_for_second_cycle_onwards"
            if @member.member_type != "GK"
              if @loan_data[:advance_insurance_available] == false
                offset          = s_deduction.meta.offset
                accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
                name            = accounting_code.name
                code            = accounting_code.code
                amount          = 0.00
                val             = s_deduction.meta.value

                multiplier  = @num_installments

                # Always advance payments for restructured loans
                if @term == "weekly"
                elsif @term == "monthly"
                  multiplier  = (multiplier * 4.3333333).to_i
                elsif @term == "semi-monthly"
                  # weird unique rule for 12 semi-monthly
                  if @num_installments ==  12
                    multiplier  = 12.5 * 2
                  elsif @num_installments == 6
                    multiplier  = 15
                  else
                    multiplier  = multiplier * 2
                  end #end semimonthly
                else
                  raise "Invalid term #{@term}"
                end #end of term

                amount  = (val * (multiplier + offset)).round(2)

                journal_entries << {
                  accounting_code_id: accounting_code.id,
                  code: code,
                  name: name,
                  amount: amount
                }

                temp_amount -= amount
                @total_debit += amount

              end #end of advance insurance
            end #end of gk
          else
            raise "Invalid deduction type algo #{s_deduction.meta.algo}"
          end
        end
      end

      # First Pass: Secondary will always be attributed to the total_debit computed after primary
      primary_amount  = @total_debit
      buffer_amount   = primary_amount

      @settings_secondary.each do |s_deduction|
        deduction_type  = s_deduction.deduction_type

        if deduction_type == "straight_one_time"
          #if @member.loans.active_or_paid.count == 0
          if @loan_cycles.size == 0
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            amount          = s_deduction.amount
            name            = accounting_code.name
            code            = accounting_code.code

#            journal_entries << {
#              accounting_code_id: accounting_code.id,
#              code: code,
#              name: name,
#              amount: amount
#            }

            temp_amount -= amount
            #@total_debit += amount
            buffer_amount += amount
          end
        elsif deduction_type == "membership_fee"
          if s_deduction.membership_type == "Cooperative" and @member.status == "pending"
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            amount          = s_deduction.amount
            name            = accounting_code.name
            code            = accounting_code.code

#            journal_entries << {
#              accounting_code_id: accounting_code.id,
#              code: code,
#              name: name,
#              amount: amount
#            }

            temp_amount -= amount
            #@total_debit += amount
            buffer_amount += amount
          elsif s_deduction.membership_type == "Insurance" and @member.insurance_status == "pending"
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            amount          = s_deduction.amount
            name            = accounting_code.name
            code            = accounting_code.code

#            journal_entries << {
#              accounting_code_id: accounting_code.id,
#              code: code,
#              name: name,
#              amount: amount
#            }

            temp_amount -= amount
            #@total_debit += amount
            buffer_amount += amount
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
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              elsif @term == "monthly"
                s_deduction.meta.term_map.monthly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              elsif @term == "semi-monthly"
                s_deduction.meta.term_map.semi_monthly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              else
                raise "Invalid term: #{@term}"
              end

#              journal_entries << {
#                accounting_code_id: accounting_code.id,
#                code: code,
#                name: name,
#                amount: amount
#              }

              #temp_amount -= amount
              #@total_debit += amount
              buffer_amount += amount
            end
          end
        elsif deduction_type == "member_type_deduction_ratio"
          target_member_type  = s_deduction.meta.member_type
          accounting_code     = AccountingCode.find(s_deduction.accounting_code_id)
          amount              = s_deduction.amount
          name                = accounting_code.name
          code                = accounting_code.code

          # Special: business_permit_available
          if s_deduction.business_permit_available.present? and s_deduction.business_permit_available == true and @loan_data[:business_permit_available].present? and @loan_data[:business_permit_available].to_s == "true"
            amount  = s_deduction.business_permit_amount

#            journal_entries << {
#              accounting_code_id: accounting_code.id,
#              code: code,
#              name: name,
#              amount: amount
#            }

            #temp_amount -= amount
            #@total_debit += amount
            buffer_amount += amount
          elsif s_deduction.for_primary_loan.present? and s_deduction.for_primary_loan == true 
            primary_loan_id = s_deduction.primary_loan_id
            loan_count = Loan.where("member_id = ? and status = ? and loan_product_id IN (?)", @member.id,"active", primary_loan_id).count
            if loan_count == 0
              if @term == "weekly"
                s_deduction.meta.term_map.weekly.each do |s|
                  
                  if s.num_installments == @num_installments
                  
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              elsif @term == "monthly"
                s_deduction.meta.term_map.monthly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              elsif @term == "semi-monthly"
                s_deduction.meta.term_map.semi_monthly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              else
                raise "Invalid term: #{@term}"
              end

#              journal_entries << {
#                accounting_code_id: accounting_code.id,
#                code: code,
#                name: name,
#                amount: amount
#              }

              #temp_amount -= amount
              #@total_debit += amount
              buffer_amount += amount
            end
          else
            if @member.member_type == "GK"
              if  s_deduction.use_for_special_loan_fund == "true"
                if @term == "weekly"
                  s_deduction.meta.term_map.weekly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                elsif @term == "monthly"
                  s_deduction.meta.term_map.monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                elsif @term == "semi-monthly"
                  s_deduction.meta.term_map.semi_monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                else
                  raise "Invalid term: #{@term}"
                end

#                journal_entries << {
#                  accounting_code_id: accounting_code.id,
#                  code: code,
#                  name: name,
#                  amount: amount
#                }

                #temp_amount -= amount
                #@total_debit += amount
                buffer_amount += amount
              end
            else
              if  s_deduction.skip_for_special_loan_fund == "true"
                if @term == "weekly"
                  s_deduction.meta.term_map.weekly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                elsif @term == "monthly"
                  s_deduction.meta.term_map.monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                elsif @term == "semi-monthly"
                  s_deduction.meta.term_map.semi_monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                else
                  raise "Invalid term: #{@term}"
                end

#                journal_entries << {
#                  accounting_code_id: accounting_code.id,
#                  code: code,
#                  name: name,
#                  amount: amount
#                }

                #temp_amount -= amount
                #@total_debit += amount
                buffer_amount += amount
              end
            end
          end
        elsif deduction_type == "deposit"
          if s_deduction.meta.algo == "term_multiplier_for_second_cycle_onwards"
            if @member.member_type != "GK"
              if @loan_data[:advance_insurance_available] == false
                offset          = s_deduction.meta.offset
                accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
                name            = accounting_code.name
                code            = accounting_code.code
                amount          = 0.00
                val             = s_deduction.meta.value

                multiplier  = @num_installments

                # Always advance payments for restructured loans
                if @term == "weekly"
                elsif @term == "monthly"
                  multiplier  = (multiplier * 4.3333333).to_i
                elsif @term == "semi-monthly"
                  # weird unique rule for 12 semi-monthly
                  if @num_installments ==  12
                    multiplier  = 12.5 * 2
                  elsif @num_installments == 6
                    multiplier  = 15
                  else
                    multiplier  = multiplier * 2
                  end #end semimonthly
                else
                  raise "Invalid term #{@term}"
                end #end of term

                amount  = val * (multiplier + offset)

#                journal_entries << {
#                  accounting_code_id: accounting_code.id,
#                  code: code,
#                  name: name,
#                  amount: amount
#                }

                #temp_amount -= amount
                #@total_debit += amount
                buffer_amount += amount

              end #end of advance insurance
            end #end of gk
          else
            raise "Invalid deduction type algo #{s_deduction.meta.algo}"
          end
        end
      end

      # Secondary will always be attributed to the total_debit computed after primary
      primary_amount  = buffer_amount

      @settings_secondary.each do |s_deduction|
        deduction_type  = s_deduction.deduction_type

        if deduction_type == "straight_one_time"
          #if @member.loans.active_or_paid.count == 0
          if @loan_cycles.size == 0
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            amount          = s_deduction.amount
            name            = accounting_code.name
            code            = accounting_code.code

#            journal_entries << {
#              accounting_code_id: accounting_code.id,
#              code: code,
#              name: name,
#              amount: amount
#            }

            temp_amount -= amount
            @total_debit += amount
          end
        elsif deduction_type == "membership_fee"
          if s_deduction.membership_type == "Cooperative" and @member.status == "pending"
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            amount          = s_deduction.amount
            name            = accounting_code.name
            code            = accounting_code.code

#            journal_entries << {
#              accounting_code_id: accounting_code.id,
#              code: code,
#              name: name,
#              amount: amount
#            }

            temp_amount -= amount
            @total_debit += amount
          elsif s_deduction.membership_type == "Insurance" and @member.insurance_status == "pending"
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            amount          = s_deduction.amount
            name            = accounting_code.name
            code            = accounting_code.code

#            journal_entries << {
#              accounting_code_id: accounting_code.id,
#              code: code,
#              name: name,
#              amount: amount
#            }

            temp_amount -= amount
            @total_debit += amount
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
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              elsif @term == "monthly"
                s_deduction.meta.term_map.monthly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              elsif @term == "semi-monthly"
                s_deduction.meta.term_map.semi_monthly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              else
                raise "Invalid term: #{@term}"
              end

#              journal_entries << {
#                accounting_code_id: accounting_code.id,
#                code: code,
#                name: name,
#                amount: amount
#              }

              #temp_amount -= amount
              @total_debit += amount
            end
          end
        elsif deduction_type == "member_type_deduction_ratio"
          target_member_type  = s_deduction.meta.member_type
          accounting_code     = AccountingCode.find(s_deduction.accounting_code_id)
          amount              = s_deduction.amount
          name                = accounting_code.name
          code                = accounting_code.code

          # Special: business_permit_available
          if s_deduction.business_permit_available.present? and s_deduction.business_permit_available == true and @loan_data[:business_permit_available].present? and @loan_data[:business_permit_available].to_s == "true"
            amount  = s_deduction.business_permit_amount

#            journal_entries << {
#              accounting_code_id: accounting_code.id,
#              code: code,
#              name: name,
#              amount: amount
#            }

            temp_amount -= amount
            @total_debit += amount
          elsif s_deduction.for_primary_loan.present? and s_deduction.for_primary_loan == true 
            primary_loan_id = s_deduction.primary_loan_id
            loan_count = Loan.where("member_id = ? and status = ? and loan_product_id IN (?)", @member.id,"active", primary_loan_id).count
            if loan_count == 0
              if @term == "weekly"
                s_deduction.meta.term_map.weekly.each do |s|
                  
                  if s.num_installments == @num_installments
                  
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              elsif @term == "monthly"
                s_deduction.meta.term_map.monthly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              elsif @term == "semi-monthly"
                s_deduction.meta.term_map.semi_monthly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              else
                raise "Invalid term: #{@term}"
              end

              temp_amount -= amount
              @total_debit += amount
            end
          else
            if @member.member_type == "GK"
              if  s_deduction.use_for_special_loan_fund == "true"
                if @term == "weekly"
                  s_deduction.meta.term_map.weekly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                elsif @term == "monthly"
                  s_deduction.meta.term_map.monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                elsif @term == "semi-monthly"
                  s_deduction.meta.term_map.semi_monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                else
                  raise "Invalid term: #{@term}"
                end

#                journal_entries << {
#                  accounting_code_id: accounting_code.id,
#                  code: code,
#                  name: name,
#                  amount: amount
#                }

                temp_amount -= amount
                @total_debit += amount
              end
            else
              if  s_deduction.skip_for_special_loan_fund == "true"
                if @term == "weekly"
                  s_deduction.meta.term_map.weekly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                elsif @term == "monthly"
                  s_deduction.meta.term_map.monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                elsif @term == "semi-monthly"
                  s_deduction.meta.term_map.semi_monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                else
                  raise "Invalid term: #{@term}"
                end

#                journal_entries << {
#                  accounting_code_id: accounting_code.id,
#                  code: code,
#                  name: name,
#                  amount: amount
#                }

                temp_amount -= amount
                @total_debit += amount
              end
            end
          end
        elsif deduction_type == "deposit"
          if s_deduction.meta.algo == "term_multiplier_for_second_cycle_onwards"
            if @member.member_type != "GK"
              if @loan_data[:advance_insurance_available] == false
                offset          = s_deduction.meta.offset
                accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
                name            = accounting_code.name
                code            = accounting_code.code
                amount          = 0.00
                val             = s_deduction.meta.value

                multiplier  = @num_installments

                # Always advance payments for restructured loans
                if @term == "weekly"
                elsif @term == "monthly"
                  multiplier  = (multiplier * 4.3333333).to_i
                elsif @term == "semi-monthly"
                  # weird unique rule for 12 semi-monthly
                  if @num_installments ==  12
                    multiplier  = 12.5 * 2
                  elsif @num_installments == 6
                    multiplier  = 15
                  else
                    multiplier  = multiplier * 2
                  end #end semimonthly
                else
                  raise "Invalid term #{@term}"
                end #end of term

                amount  = val * (multiplier + offset)

#                journal_entries << {
#                  accounting_code_id: accounting_code.id,
#                  code: code,
#                  name: name,
#                  amount: amount
#                }

                temp_amount -= amount
                @total_debit += amount

              end #end of advance insurance
            end #end of gk
          else
            raise "Invalid deduction type algo #{s_deduction.meta.algo}"
          end
        end
      end

      # Secondary will always be attributed to the total_debit computed after primary
      primary_amount  = @total_debit

      @settings_secondary.each do |s_deduction|
        deduction_type  = s_deduction.deduction_type

        if deduction_type == "straight_one_time"
          #if @member.loans.active_or_paid.count == 0
          if @loan_cycles.size == 0
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            amount          = s_deduction.amount
            name            = accounting_code.name
            code            = accounting_code.code

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount.round(2)
            }

            temp_amount -= amount
            #@total_debit += amount
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
              amount: amount.round(2)
            }

            temp_amount -= amount
            #@total_debit += amount
          elsif s_deduction.membership_type == "Insurance" and @member.insurance_status == "pending"
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            amount          = s_deduction.amount
            name            = accounting_code.name
            code            = accounting_code.code

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount.round(2)
            }

            temp_amount -= amount
            #@total_debit += amount
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
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              elsif @term == "monthly"
                s_deduction.meta.term_map.monthly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              elsif @term == "semi-monthly"
                s_deduction.meta.term_map.semi_monthly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              else
                raise "Invalid term: #{@term}"
              end

              journal_entries << {
                accounting_code_id: accounting_code.id,
                code: code,
                name: name,
                amount: amount.round(2)
              }

              #temp_amount -= amount
              #@total_debit += amount
            end
          end
        elsif deduction_type == "member_type_deduction_ratio"
          target_member_type  = s_deduction.meta.member_type
          accounting_code     = AccountingCode.find(s_deduction.accounting_code_id)
          amount              = s_deduction.amount
          name                = accounting_code.name
          code                = accounting_code.code

          # Special: business_permit_available
          if s_deduction.business_permit_available.present? and s_deduction.business_permit_available == true and @loan_data[:business_permit_available].present? and @loan_data[:business_permit_available].to_s == "true"
            amount  = s_deduction.business_permit_amount

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount.round(2)
            }

            temp_amount -= amount
            #@total_debit += amount
          elsif s_deduction.for_primary_loan.present? and s_deduction.for_primary_loan == true 
            primary_loan_id = s_deduction.primary_loan_id
            loan_count = Loan.where("member_id = ? and status = ? and loan_product_id IN (?)", @member.id,"active", primary_loan_id).count
            if loan_count == 0
              if @term == "weekly"
                s_deduction.meta.term_map.weekly.each do |s|
                  
                  if s.num_installments == @num_installments
                  
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              elsif @term == "monthly"
                s_deduction.meta.term_map.monthly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * primary_amount).round(2)
                  end
                end
              elsif @term == "semi-monthly"
                s_deduction.meta.term_map.semi_monthly.each do |s|
                  if s.num_installments == @num_installments
                    amount  = (s.ratio * primary_amount).round(2)
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
          else
            if @member.member_type == "GK"
              if  s_deduction.use_for_special_loan_fund == "true"
                if @term == "weekly"
                  s_deduction.meta.term_map.weekly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                elsif @term == "monthly"
                  s_deduction.meta.term_map.monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                elsif @term == "semi-monthly"
                  s_deduction.meta.term_map.semi_monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                else
                  raise "Invalid term: #{@term}"
                end

                journal_entries << {
                  accounting_code_id: accounting_code.id,
                  code: code,
                  name: name,
                  amount: amount.round(2)
                }

                temp_amount -= amount
              end
            else
              if  s_deduction.skip_for_special_loan_fund == "true"
                if @term == "weekly"
                  s_deduction.meta.term_map.weekly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                elsif @term == "monthly"
                  s_deduction.meta.term_map.monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
                    end
                  end
                elsif @term == "semi-monthly"
                  s_deduction.meta.term_map.semi_monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * primary_amount).round(2)
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
          end
        elsif deduction_type == "deposit"
          if s_deduction.meta.algo == "term_multiplier_for_second_cycle_onwards"
            if @member.member_type != "GK"
              if @loan_data[:advance_insurance_available] == false
                offset          = s_deduction.meta.offset
                accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
                name            = accounting_code.name
                code            = accounting_code.code
                amount          = 0.00
                val             = s_deduction.meta.value

                multiplier  = @num_installments

                # Always advance payments for restructured loans
                if @term == "weekly"
                elsif @term == "monthly"
                  multiplier  = (multiplier * 4.3333333).to_i
                elsif @term == "semi-monthly"
                  # weird unique rule for 12 semi-monthly
                  if @num_installments ==  12
                    multiplier  = 12.5 * 2
                  elsif @num_installments == 6
                    multiplier  = 15
                  else
                    multiplier  = multiplier * 2
                  end #end semimonthly
                else
                  raise "Invalid term #{@term}"
                end #end of term

                amount  = (val * (multiplier + offset)).round(2)

                journal_entries << {
                  accounting_code_id: accounting_code.id,
                  code: code,
                  name: name,
                  amount: amount
                }

                temp_amount -= amount

              end #end of advance insurance
            end #end of gk
          else
            raise "Invalid deduction type algo #{s_deduction.meta.algo}"
          end
        end
      end

      # Offset round off
      rounded_off_amount  = @total_debit.ceil
      credit_so_far       = journal_entries.inject(0){ |sum, h| sum + h[:amount] }

      if rounded_off_amount != credit_so_far
        # Get offset and add as part of credit
        offset = (rounded_off_amount - credit_so_far).round(2)

        if offset > 0
          accounting_code = AccountingCode.find(@settings_offset.accounting_code_id)
          code            = accounting_code.code
          name            = accounting_code.name
          amount          = offset

          journal_entries << {
            accounting_code_id: accounting_code.id,
            code: code,
            name: name,
            amount: amount
          }
        else
          @miscellaneous_offset = offset
        end
      end

      # Set @total_debit to rounded off value
      @total_debit = rounded_off_amount

      return journal_entries
    end

    def default_particular
      "TODO: Changeme"
    end
  end
end
