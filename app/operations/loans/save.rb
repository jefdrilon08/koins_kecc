module Loans
  class Save
    def initialize(config:, persist: true)
      @config       = config
    
      @loan_data    = @config[:loan_data]
      @user         = @config[:user]

      @loan_product = LoanProduct.where(id: @loan_data[:loan_product_id]).first
    
  
      @member       = Member.where(id: @loan_data[:member_id]).first
      @branch       = Branch.where(id: @loan_data[:branch_id]).first
      @center       = Center.where(id: @loan_data[:center_id]).first
      
      if @loan_data[:bank_id].present?
        @bank_transfer = BankTransfer.find(@loan_data[:bank_id])
      end

      #@loan_product_type = LoanProductType.find_by_id(@loan_data[:loan_product_type_id])
      @loan_product_tagging = LoanProductTagging.find_by_id(@loan_data[:loan_product_tagging_id])
      #raise @loan_product_tagging.inspect


      @co_maker_profile_picture       = @config[:co_maker_profile_picture]
      @co_maker_three_profile_picture = @config[:co_maker_three_profile_picture]
      @payment_type = @config[:payment_type]
      @sub_type = @config[:sub_type]

      @persist  = persist

      @loan = Loan.new

      if @loan_data[:id].present?
        @loan = Loan.find(@loan_data[:id])
      end

      @member_data  = @member.data.with_indifferent_access

      # Settings
      @settings_loan_products = Settings.loan_products

      if @settings_loan_products.blank?
        raise "settings_loan_products not found"
      end

      # Actual loan product settings
      @settings_loan_products.each do |s|
        if s.loan_product_id == @loan_product.id
          @settings = s
        end
      end

      if @settings.blank?
        raise "No settings foud for loan_product #{@loan_product.id}"
      end
    end
    
    def execute!

        if  @loan_data[:paid_loans].present?
            @loan_data[:data] ||= {}
            @loan_data[:data][:paid_loans] = @loan_data[:paid_loans]
        end

      if @loan_data[:paid_loan].present?
          paid = @loan_data[:paid_loan]

          @loan_data[:data] ||= {}
          @loan_data[:data][:paid_loan] = {
            loan_product_id: paid[:loan_product_id] || nil,
            total_paid:      paid[:total_paid]      || 0,
            interest_paid:   paid[:interest_paid]   || 0,
            principal_paid:  paid[:principal_paid]  || 0,
            total_balance:   paid[:total_balance]   || 0
          }
      end


      @loan.pn_number         = @loan_data[:pn_number]
      @loan.date_prepared     = @loan_data[:date_prepared]
      @loan.date_released     = @loan_data[:date_released]
      @loan.principal         = @loan_data[:principal].to_f.round(2)
      @loan.num_installments  = @loan_data[:num_installments]
      @loan.project_type_id   = @loan_data[:project_type_id]
      @loan.term              = @loan_data[:term]
      @loan.data              = @loan_data[:data] || {}
    
      # Save modepayment_type_of and sub_type into loan data
      @loan.data[:payment_type]    = @payment_type
      @loan.data[:sub_type]   = @sub_type
    
      if @bank_transfer.present?
        @bank_data = {
          bank_transfer_id: @bank_transfer.id, 
          bank_transfer_name: @bank_transfer.name, 
          bank_transfer_amount: @bank_transfer.amount.to_f,
          accounting_entry_id: @bank_transfer.accounting_entry_id,
          transfer_option_id: @bank_transfer.transfer_option_id
        }
        @loan.data[:bank_transfer] = @bank_data
      end

      # Setup loan cycle
      @loan_cycles            = @member_data[:loan_cycles]

      if @loan_cycles.blank? || @loan_cycles.size == 0
        @loan.cycle = 1
      else
        @loan_cycles.each_with_index do |c, i|
          if c[:loan_product_id] == @loan_product.id
            @loan.cycle = c[:cycle] + 1
          end
        end
      end
      
      @loan.member                = @member
      @loan.branch                = @branch
      @loan.center                = @center
      @loan.loan_product          = @loan_product
      @loan.loan_product_type     = nil #@loan_product_type
      if @loan_product_tagging.nil?
        @loan.loan_product_tagging_id = nil
      else
        @loan.loan_product_tagging_id = @loan_product_tagging.id
      end
      @loan.monthly_interest_rate = @loan_product.monthly_interest_rate

      if @settings.use_term_interest.present?
        @settings.use_term_interest.each do |t|
          if t.term == @loan.term and @loan.num_installments > t.min_num_installments and @loan.num_installments <= t.max_num_installments
            @loan.monthly_interest_rate = t.monthly_interest_rate
          end
        end
      end

      #special Interest for kabuhayan W3
      if @settings.special_interest_area_id == @branch.cluster.area_id
        @settings.special_use_term_interest.each do |t|
          if t.term == @loan.term and @loan.num_installments > t.min_num_installments and @loan.num_installments <= t.max_num_installments
            @loan.monthly_interest_rate = t.monthly_interest_rate
          end
        end
      end
      
      if @settings.zero_interest != "true" # for loans has interest/Normal loans
        params  = {
          principal: @loan.principal,
          annual_interest_rate: (@loan.monthly_interest_rate * 12),
          num_installments: @loan_data[:num_installments],
          term: @loan_data[:term]
        }


        result  = ::Finance::Amortize.new(
                    params: params
                  ).execute!
        
        @loan.principal_balance = @loan.principal
        @loan.interest_balance  = result[:interest]
        @loan.interest          = result[:interest]
        @loan.principal_paid    = 0.00
        @loan.interest_paid     = 0.00

        if !@loan.new_record?
          @loan.amortization_schedule_entries.delete_all
        end

        result[:schedule].each do |o|
          principal   = o[:principal].to_f.round(2)
          interest    = o[:interest].to_f.round(2)
          amount_due  = (principal + interest).round(2)

          amort = AmortizationScheduleEntry.new(
                    principal: principal,
                    interest: interest,
                    principal_balance: principal,
                    interest_balance: interest,
                    principal_paid: 0.00,
                    interest_paid: 0.00,
                    amount_due: amount_due
                  )
          @loan.amortization_schedule_entries << amort
        end

      elsif  @settings.zero_interest == "true" #for loans has zero interest
         params  = {
          principal: @loan.principal,
          annual_interest_rate: (@loan.monthly_interest_rate * 12),
          num_installments: @loan_data[:num_installments],
          term: @loan_data[:term]
          }


        result  = ::Finance::Amortize.new(
                    params: params
                  ).execute!
        
        @loan.principal_balance = @loan.principal
        @loan.interest_balance  = result[:interest]
        @loan.interest          = result[:interest]
        @loan.principal_paid    = 0.00
        @loan.interest_paid     = 0.00

        if !@loan.new_record?
          @loan.amortization_schedule_entries.delete_all
        end
          buffer_principal  = 0.00
          result[:schedule].each do |o|
            principal   = o[:principal].to_i.round(2)
            interest    = o[:interest].to_f.round(2)
            amount_due  = (principal + interest).round(2)

            buffer_principal += principal

            @loan.amortization_schedule_entries.build(
            principal: principal,
            interest: interest,
            principal_balance: principal,
            interest_balance: interest,
            principal_paid: 0.00,
            interest_paid: 0.00,
            amount_due: amount_due
            )
          end
          ### EQUALIZE ###
          if buffer_principal > @loan.principal
            diff = buffer_principal - @loan.principal
            @loan.amortization_schedule_entries.last.principal  = @loan.amortization_schedule_entries.last.principal - diff
            @loan.amortization_schedule_entries.last.amount_due = @loan.amortization_schedule_entries.last.amount_due - diff
            @loan.amortization_schedule_entries.last.principal_balance = @loan.amortization_schedule_entries.last.principal
          elsif buffer_principal < @loan.principal
            diff = @loan.principal - buffer_principal
            @loan.amortization_schedule_entries.last.principal = @loan.amortization_schedule_entries.last.principal + diff
            @loan.amortization_schedule_entries.last.amount_due = @loan.amortization_schedule_entries.last.amount_due + diff
            @loan.amortization_schedule_entries.last.principal_balance = @loan.amortization_schedule_entries.last.principal 
          end
      end #end of zero interest


      # Build accounting entry data
      particular  = "Release of Loan - #{@member.first_name} #{@member.middle_name} #{@member.last_name} cv# #{@loan.voucher_check_voucher_number} ck# #{@loan.voucher_bank_check_number} clip# #{@loan.clip_number}"
      particular_for_remittance  = "Release of Loan via Remittance - #{@member.first_name} #{@member.middle_name} #{@member.last_name} cv# #{@loan.voucher_check_voucher_number} ck# #{@loan.voucher_bank_check_number} clip# #{@loan.clip_number}"

      if @loan.data.present? and @loan.data.with_indifferent_access[:accounting_entry].present?
        @book = @loan.data.with_indifferent_access[:accounting_entry][:book]
      end
        if @payment_type == 'USSC' && @sub_type == 'E-WALLET'
          accounting_entry_data = ::Loans::BuildAccountingEntryForRemittance.new(
                                    config: {
                                      member: @member,
                                      loan_product: @loan_product,
                                      amount: @loan.principal,
                                      term: @loan.term,
                                      num_installments: @loan.num_installments,
                                      particular: particular_for_remittance,
                                      book: @book,
                                      bank_data: @bank_data,
                                      loan: @loan
                                    }
                                  ).execute!
          else
            accounting_entry_data = ::Loans::BuildAccountingEntry.new(
              config: {
                member: @member,
                loan_product: @loan_product,
                amount: @loan.principal,
                term: @loan.term,
                num_installments: @loan.num_installments,
                particular: particular,
                book: @book,
                bank_data: @bank_data,
                loan: @loan
              }
            ).execute!
        end
      @loan.data[:accounting_entry] = accounting_entry_data

      if @persist
        if @co_maker_profile_picture.present? and !valid_url?(@co_maker_profile_picture)
          decoded_data  = Base64.decode64(@co_maker_profile_picture.split(',')[1])

          @loan.co_maker_relative_profile_picture = {
            io: StringIO.new(decoded_data),
            content_type: 'image/jpeg',
            filename: 'co_maker.jpg'
          }
        end

        if @co_maker_three_profile_picture.present? and !valid_url?(@co_maker_three_profile_picture)
          decoded_data  = Base64.decode64(@co_maker_three_profile_picture.split(',')[1])

          @loan.co_maker_non_relative_profile_picture = {
            io: StringIO.new(decoded_data),
            content_type: 'image/jpeg',
            filename: 'co_maker_non_relative.jpg'
          }
        end


        @loan.save! 
      end
 # Get the active loan
active_loan = @member.loans.active.where(loan_product_id: @loan_product.id).first

if active_loan.present?
  # Create an entry for full payment
  
  full_payment_entry = ::Loans::BuildAccountingEntryForFullPayment.new(loan: active_loan, current_user: @user, particular: nil).execute!

  # Remove the creation and saving of accounting entry
  # accounting_entry = ::Accounting::AccountingEntries::Save.new(
  #   config: {
  #     id: nil,
  #     accounting_entry_data: full_payment_entry,
  #     user: @user
  #   }
  # ).execute!
  
  # Remove approval of the accounting entry
  # accounting_entry = ::Accounting::AccountingEntries::Approve.new(
  #   config: {
  #     accounting_entry: accounting_entry,
  #     user: @user
  #   }
  # ).execute!

  # Create data for full payment details without unnecessary fields
  full_payment = {
    present_loan_id: active_loan.id, 
    pn_number_for_full_payment: Loan.find(active_loan.id).pn_number,
    principal_paid: active_loan.principal_balance.to_f,
    interest_balance: active_loan.interest_balance,
    bank_check_number: active_loan.data["voucher"]["bank_check_number"],  
    check_number: active_loan.data["voucher"]["check_number"],
    
    
   # clip_number: active_loan.data["clip_number"]
  }

  
  # Update the loan to save the full payment data without creating an entry
  loan_inf = Loan.find(@loan.id)
  loan_inf_data = loan_inf.data.with_indifferent_access

  # Replace arrays with single hash objects
  loan_inf_data[:for_full_payment] = full_payment
  loan_inf_data[:for_full_payment_entries] = full_payment_entry

  # Update the loan data with the new full payment details
  loan_inf.update(data: loan_inf_data)
end
      @loan
    end

    # Convert to base64 if profile pictures are URLs
    def valid_url?(url)
      return false if url.include?("<script")
      url_regexp = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
      url =~ url_regexp ? true : false
    end
  end
end
