module Loans
  class Save < AppValidator
    def initialize(config:)
      @config       = config
      @loan_data    = @config[:loan_data]
      @user         = @config[:user]
      @loan_product = LoanProduct.where(id: @loan_data[:loan_product_id]).first
      @member       = Member.where(id: @loan_data[:member_id]).first
      @branch       = Branch.where(id: @loan_data[:branch_id]).first
      @center       = Center.where(id: @loan_data[:center_id]).first

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
      @loan.pn_number         = @loan_data[:pn_number]
      @loan.date_prepared     = @loan_data[:date_prepared]
      @loan.date_released     = @loan_data[:date_released]
      @loan.principal         = @loan_data[:principal].to_f.round(2)
      @loan.num_installments  = @loan_data[:num_installments]
      @loan.project_type_id   = @loan_data[:project_type_id]
      @loan.term              = @loan_data[:term]
      @loan.data              = @loan_data[:data]

      # Setup loan cycle
      @loan_cycles  = @member_data[:loan_cycles]

      if @loan_cycles.blank?
        @loan.cycle = 1
      else
        found = false

        @loan_cycles.each do |c|
          if c[:loan_product_id] == @loan_product.id
            @loan.cycle = c[:cycle] + 1
            found       = true
          end
        end

        if !found
          @loan.cycle = 1
        end
      end

      @loan.member                = @member
      @loan.branch                = @branch
      @loan.center                = @center
      @loan.loan_product          = @loan_product
      @loan.monthly_interest_rate = @loan_product.monthly_interest_rate

      if @settings.use_term_interest.present?
        @settings.use_term_interest.each do |t|
          if t.term == @loan.term and @loan.num_installments > t.min_num_installments and @loan.num_installments <= t.max_num_installments
            @loan.monthly_interest_rate = t.monthly_interest_rate
          end
        end
      end

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
      @loan.interest_balance  = 0.00
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

      # Build accounting entry data
      particular  = "Release of Loan - #{@member.first_name} #{@member.middle_name} #{@member.last_name} cv# #{@loan.voucher_check_voucher_number} ck# #{@loan.voucher_bank_check_number} clip# #{@loan.clip_number}"

      if @loan.data.present? and @loan.data.with_indifferent_access[:accounting_entry].present?
        @book = @loan.data.with_indifferent_access[:accounting_entry][:book]
      end
      accounting_entry_data = ::Loans::BuildAccountingEntry.new(
                                config: {
                                  member: @member,
                                  loan_product: @loan_product,
                                  amount: @loan.principal,
                                  term: @loan.term,
                                  num_installments: @loan.num_installments,
                                  particular: particular,
                                  book: @book,
                                  loan: @loan
                                }
                              ).execute!

      @loan.data[:accounting_entry] = accounting_entry_data

      @loan.save!

      @loan
    end
  end
end
