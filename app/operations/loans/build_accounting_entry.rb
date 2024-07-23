module Loans
  class BuildAccountingEntry
    def initialize(config:)
      @config       = config
      @bank_data    = @config[:bank_data]
      @loan         = @config[:loan]
      @member       = @config[:member]
      @branch       = @member.branch
      @loan_product = @config[:loan_product]
      @amount       = @config[:amount].to_f.round(2)
      @book         = @config[:book] || "CDB"
      @loan_data    = @loan.data.with_indifferent_access
      @voucher_data = @loan_data[:voucher]

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
      @settings = nil

      Settings.loan_products.each do |s|
        if s.loan_product_id == @loan_product.id
          @settings = s
        end
      end

      if @settings.blank?
        raise "Settings not foud for loan product #{@loan_product.id}: #{@loan_product.name}. Please check production.yml"
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
      @accounting_entry_data[:data] = {
        or_number: @loan_data[:or_number],
        ar_number: "",
        check_number: @voucher_data[:bank_check_number],
        check_voucher_number: @voucher_data[:check_number],
        date_of_check: @voucher_data[:date_of_check],
        sub_reference_number: "",
        payee: "#{@member.full_name}"
      }
    end

    def build_debit_journal_entries!
      journal_entries = []

      # Receivable
      accounting_code = AccountingCode.find(@settings.receivable_accounting_code_id)
      amount          = @amount
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

      # Deductions
      @settings.deductions.each do |s_deduction|
        deduction_type  = s_deduction.deduction_type
        if deduction_type == "share_capital_fee"
            total_member_shares = MemberAccount.where(member_id: @member.id, account_subtype: "Share Capital").last.balance.to_f / 100.0
            
            @share_capital_deposit = Settings.defaults["share_capital_deposits"].last["regular_share_deposits"].select{ |a|   @loan.principal.to_f >= a["min_amount"]  and @loan.principal.to_f <= a["max_amount"]}

            partial_number_of_share =  total_member_shares.to_i +  @share_capital_deposit.last["number_of_share"]
            
            if s_deduction.max_share < partial_number_of_share
              share_avail =  s_deduction.max_share  - total_member_shares
              @need_total_share_to_avail = share_avail
            else
              @need_total_share_to_avail = @share_capital_deposit.last["number_of_share"].to_f
            end
            #raise partial_number_of_share.inspect
            if total_member_shares <= s_deduction.max_share.to_i
              @total_share_paid =  @need_total_share_to_avail.to_f * s_deduction.amount.to_f
              
            end
            accounting_code = AccountingCode.find("370f5e4f-e4c8-454e-90b2-17919cc5ef92")
            amount          = @total_share_paid
            name            = accounting_code.name
            code            = accounting_code.code
            
          

            if s_deduction["skip_sc"].present?
              number_of_sharecap = MemberAccount.where(account_subtype: "Share Capital").last.balance.to_f
              if number_of_sharecap > 0
                journal_entries << {
                  accounting_code_id: accounting_code.id,
                  code: code,
                  name: name,
                  amount: amount
                }
                temp_amount -= amount
              end
            
            else
              if (@member_data[:entry_point_loan_cycle].to_i + 1.to_i).to_i > 1
      
                if @loan.data["share_capital_available"].nil? || @loan.data["share_capital_available"] == false
                  journal_entries << {
                    accounting_code_id: accounting_code.id,
                    code: code,
                    name: name,
                    amount: amount
                  }
                  #temp_amount -= amount
                end
            end
            
            
            end

        elsif deduction_type == "straight_one_time"
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
          elsif s_deduction.membership_type == "Insurance" and @member.insurance_status == "pending"
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


              #temp_amount -= amount
            end
          end
        elsif deduction_type == "member_type_deduction_ratio"
          target_member_type  = s_deduction.meta.member_type
          accounting_code     = AccountingCode.find(s_deduction.accounting_code_id)
          amount              = s_deduction.amount
          name                = accounting_code.name
          code                = accounting_code.code
          
          #raise s_deduction.special_insurance.inspect
          #if s_deduction.special_insurance.present? and s_deduction.special_insurance.to_s == "true"
          #  raise @amount.inspect
          #end
          # Special: business_permit_available
          if s_deduction.business_permit_available.present? and s_deduction.business_permit_available == true and @loan_data[:business_permit_available].present? and @loan_data[:business_permit_available].to_s == "true"
            #if s_deduction.sms_amount_status.present? and s_deduction.sms_amount_status == true and @loan_data[:sms_fee_available] == false
            #  amount  = s_deduction.business_permit_amount + s_deduction.sms_amount.to_f
            #else 
            #  amount  = s_deduction.business_permit_amount
            #end



            if @loan_data[:service_fee_available].present? and  @loan_data[:service_fee_available].to_s == "true" and s_deduction.name == "Service Fee"
              amount = s_deduction.sms_amount.to_f
            else

              if s_deduction.skip_term_map == false
                if @term == "weekly"
                  s_deduction.meta.term_map.weekly.each do |s|
                    
                    if s.num_installments == @num_installments
                    
                      amount  = (0.01 * @amount).round(2) + s_deduction.sms_amount.to_f
                    end
                  end
                elsif @term == "monthly"
                  s_deduction.meta.term_map.monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (0.01 * @amount).round(2) + s_deduction.sms_amount.to_f
                    end
                  end
                elsif @term == "semi-monthly"
                  s_deduction.meta.term_map.semi_monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (0.01 * @amount).round(2) + s_deduction.sms_amount.to_f
                    end
                  end
                else
                  raise "Invalid term: #{@term}"
                end
              else
                amount = s_deduction.sms_amount.to_f
              end
            end

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount
            }

            temp_amount -= amount
 
          elsif s_deduction.sms_amount_status.present? and s_deduction.sms_amount_status == true and @loan_data[:sms_fee_available] == false
          #raise @loan_data[:sms_fee_available].inspect
          #and @loan_data[:business_permit_available].present? and @loan_data[:business_permit_available].to_s == "true"
            #amount  = s_deduction.sms_amount
            if @loan_data[:service_fee_available].present? and  @loan_data[:service_fee_available].to_s == "true" and s_deduction.name == "Service Fee"
              amount = s_deduction.sms_amount.to_f
            else

              if s_deduction.skip_term_map == false
                if @term == "weekly"
                  s_deduction.meta.term_map.weekly.each do |s|
                    
                    if s.num_installments == @num_installments
                    
                      amount  = (s.ratio * @amount).round(2) + s_deduction.sms_amount.to_f
                    end
                  end
                elsif @term == "monthly"
                  s_deduction.meta.term_map.monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * @amount).round(2) + s_deduction.sms_amount.to_f
                    end
                  end
                elsif @term == "semi-monthly"
                  s_deduction.meta.term_map.semi_monthly.each do |s|
                    if s.num_installments == @num_installments
                      amount  = (s.ratio * @amount).round(2) + s_deduction.sms_amount.to_f
                    end
                  end
                else
                  raise "Invalid term: #{@term}"
                end
              else
                amount = s_deduction.sms_amount.to_f
              end
            end

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: amount
            }

            temp_amount -= amount

          #elsif @member.member_type  == target_member_type
          elsif @loan_data[:service_fee_available].present? and  @loan_data[:service_fee_available].to_s == "true" and s_deduction.name == "Service Fee"
            target_member_type  = s_deduction.meta.member_type
            accounting_code     = AccountingCode.find(s_deduction.accounting_code_id)
            amount              = s_deduction.amount
            name                = accounting_code.name
            code                = accounting_code.code
            
            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: code,
              name: name,
              amount: 0.0
            }
            

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
            end

          elsif s_deduction.skip_for_membership_type.present? and s_deduction.skip_for_membership_type_status == true
            membership_type_present = s_deduction.skip_for_membership_type.select{ |a| a==@member.member_type  }.count
            
            if membership_type_present == 0
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

          else
            if @member.member_type == "GK" || @member.member_type == "GK-Kaagapay"
              #for special loan product  for GPF
              if  s_deduction.use_for_special_loan_fund == "true" and s_deduction.special_loan_product == "true"
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

                if journal_entries.present?
                  @service_f_original= journal_entries[0][:amount]
                else
                  @service_f_original= 0.00
                end

                
                journal_entries << {
                  accounting_code_id: accounting_code.id,
                  code: code,
                  name: name,
                  amount: amount
                }
                
                temp_amount -= amount
                clip_amount  = amount
                service_fee  =  temp_amount - temp_amount.to_i #add offset amount to service fee

                #for k-yakap
                @service_fee_original= 0.00
                if  @settings.special_loan_product == "true"
                  j_entry_service_fee = journal_entries #get service fee from journal entry
                  set= @settings.deductions #get loan settings deduction

                  set.each do |ss| #loop for settings deduction to get service fee
                      j_entry_service_fee.each do |js| # loop for journal entry to get service fee
                        if ss["accounting_code_id"] == js[:accounting_code_id] and ss["service_fee_special_loan"] == "true"
                          @service_fee_original= js[:amount] #original service fee amount
                          js[:amount] = (@service_fee_original + service_fee).round(2)
                        end
                      end
                  end
                #end for kyakap

                #for bene-w4 
                else
                  accounting_code_serv    = AccountingCode.find(s_deduction.accounting_code_for_special_loan)
                  amount_serv             = service_fee.to_f.round(2)
                  name_serv               = accounting_code_serv.name
                  code_serv               = accounting_code_serv.code
                  
                  journal_entries << {
                    accounting_code_id: accounting_code_serv.id,
                    code: code_serv,
                    name: name_serv,
                    amount: amount_serv
                  }
                end
                
                temp_amount = temp_amount.to_i
                @temp_amount= temp_amount
               
                #end of special loan product

              elsif s_deduction.use_for_special_loan_fund == "true" 
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
            else
              #for special loan product
              if  s_deduction.skip_for_special_loan_fund == "true" and s_deduction.special_loan_product == "true"
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
                clip_amount  = amount
                service_fee  =  temp_amount - temp_amount.to_i #add offset amount to service fee

                #for k-yakap
                @service_fee_original= 0.00
                if  @settings.special_loan_product == "true"
                  j_entry_service_fee = journal_entries #get service fee from journal entry
                  set= @settings.deductions #get loan settings deduction

                  set.each do |ss| #loop for settings deduction to get service fee
                      j_entry_service_fee.each do |js| # loop for journal entry to get service fee
                        if ss["accounting_code_id"] == js[:accounting_code_id] and ss["service_fee_special_loan"] == "true"
                          @service_fee_original= js[:amount] #original service fee amount
                          js[:amount] = (@service_fee_original + service_fee).round(2)
                        end
                      end
                  end
                #end for kyakap

                #for bene-w4 
                else
                  accounting_code_serv    = AccountingCode.find(s_deduction.accounting_code_for_special_loan)
                  amount_serv             = service_fee.to_f.round(2)
                  name_serv               = accounting_code_serv.name
                  code_serv               = accounting_code_serv.code
                  
                  journal_entries << {
                    accounting_code_id: accounting_code_serv.id,
                    code: code_serv,
                    name: name_serv,
                    amount: amount_serv
                  }
                end
                
                temp_amount = temp_amount.to_i
                @temp_amount= temp_amount
               
                #end of special loan product

              elsif  s_deduction.skip_for_special_loan_fund == "true" 
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
          end
        elsif deduction_type == "deposit"
          

          if s_deduction.meta.algo == "term_multiplier_for_second_cycle_onwards" 
           
            #if @member.member_type != "GK-Kaagapay" && @member.member_type != "GK"
            if  @member.member_type != "GK"
            
              if @loan_data[:advance_insurance_available] == false
                offset          = s_deduction.meta.offset
                accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
                name            = accounting_code.name
                code            = accounting_code.code
                amount          = 0.00
                val             = s_deduction.meta.value

                multiplier  = @num_installments

                loan_cycle  = @loan_cycles.select{ |c| c[:cycle] >= 1 and c[:loan_product_id] == @loan_product.id }.first

                if (@loan_product.is_entry_point and @entry_point_loan_cycle_count >= 1) || loan_cycle.present?
                  #if @member.loans.paid.where(loan_product_id: @loan_product.id).count >= 1
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

                elsif loan_cycle == nil and @member.member_type == "Kaagapay"
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
                      
                else
                  amount  = val
                end #loan cycle presents
                journal_entries << {
                  accounting_code_id: accounting_code.id,
                  code: code,
                  name: name,
                  amount: amount
                }

                temp_amount -= amount
              
              end #end of advance insurance
            end #end of gk
          elsif s_deduction.special_loan == "true"  
           #for special Loan bene w4
            if @member.member_type != "GK"  
              lf_amount = @temp_amount * 0.75
              rf_amount = @temp_amount * 0.25
              accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
              name            = accounting_code.name
              code            = accounting_code.code

              if s_deduction.meta[:account_subtype] == "Life Insurance Fund"
              journal_entries << {
                  accounting_code_id: accounting_code.id,
                  code: code,
                  name: name,
                  amount: lf_amount
                }

              elsif s_deduction.meta[:account_subtype] == "Retirement Fund"
                journal_entries << {
                  accounting_code_id: accounting_code.id,
                  code: code,
                  name: name,
                  amount: rf_amount
                }
              end
             temp_amount = 0.00

            end
            
          elsif s_deduction.meta.algo == "term_multiplier_for_insurance_amount"
            
            amount = @amount
            accounting_code = AccountingCode.find(s_deduction.accounting_code_id)
            name            = accounting_code.name
            code            = accounting_code.code
            #for_insurance = (amount.to_i/100.to_i) * 100.to_i 
            if amount >= 300 and amount <= 499
              total_amount = s_deduction.meta.value * 15 
            elsif amount >= 500 and amount <= 599
              total_amount = s_deduction.meta.value * 25 
            elsif amount >= 600 and amount <= 699
              total_amount = s_deduction.meta.value * 30
            elsif amount >= 700 and amount <= 799
              total_amount = s_deduction.meta.value * 35
            elsif amount >= 800 and amount <= 899
              total_amount = s_deduction.meta.value * 40
            elsif amount >= 900 and amount <= 999
              total_amount = s_deduction.meta.value * 50
            else
              total_amount = s_deduction.meta.value * 40
            end
              #raise total_amount.inspect
              journal_entries << {
                  accounting_code_id: accounting_code.id,
                  code: code,
                  name: name,
                  amount: total_amount
                }

    
             temp_amount -= amount
          
          #raise journal_entries.inspect
           #insurance_amount = s_deduction.meta.value
            #raise "jef".inspect
          else
            raise "Invalid deduction type algo #{s_deduction.meta.algo}"
          end
        end
      end

      
      # Insurance membership
#      if @member.insurance_pending?
#        accounting_code = AccountingCode.find(@settings_insurance_membership.accounting_code_id)
#        amount          = @settings_insurance_membership.fee
#
#        journal_entries << {
#          accounting_code_id: accounting_code.id,
#          code: accounting_code.code,
#          name: accounting_code.name,
#          amount: amount
#        }
#
#        temp_amount -= amount
#      end

        
      if @bank_data.present?
      
        accounting_code = AccountingCode.find(@bank_data[:accounting_entry_id])
        amount = @bank_data[:bank_transfer_amount].to_f
  
        journal_entries << {
                  accounting_code_id: accounting_code.id,
                  code: accounting_code.code,
                  name: accounting_code.name,
                  amount: amount
        }
        temp_amount -= amount
      end
      # Cash in bank for amount released
      accounting_code = AccountingCode.find(@settings_branch_accounting_codes.cash_in_bank_accounting_code_id)

      if @settings.amount_released_accounting_code_id.present?
        accounting_code = AccountingCode.find(@settings.amount_released_accounting_code_id)
      end
      
      journal_entries << {
        accounting_code_id: accounting_code.id,
        code: accounting_code.code,
        name: accounting_code.name,
        amount: temp_amount
      }

      # Update amount
      @amount_released  = temp_amount
      grouped_data = journal_entries.group_by { |entry| entry[:code] }

      # Sum the amounts and create new combined entries
      journal_entries = grouped_data.map do |code, entries|
        accounting_code_id = entries.first[:accounting_code_id]
        name = entries.first[:name]
        amounts = entries.map { |entry| entry[:amount] }.compact
        {
            accounting_code_id: entries.first[:accounting_code_id],
            code: code,
            name: entries.first[:name],
            amount: entries.sum { |entry| entry[:amount] }
        } if accounting_code_id && name && amounts.any?
      end.compact
      #raise journal_entries.map{|a| a}.inspect
      journal_entries
    end

    def default_particular
      "TODO: Changeme"
    end
  end
end
