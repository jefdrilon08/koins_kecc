module Loans
  class RemoteApply
    attr_accessor :loan

    def initialize(config:, persist: true)
      @config = config

      @persist  = persist

      @member           = @config[:member]
      @loan_product     = @config[:loan_product]
      @pn_number        = @config[:pn_number]
      @co_maker_one     = @config[:co_maker_one]
      @co_maker_two     = @config[:co_maker_two]
      @amount           = @config[:amount]
      @term             = @config[:term]
      @num_installments = @config[:num_installments]
      @project_type     = @config[:project_type]

      # CLIP related info
      @clip_first_name    = @config[:clip_first_name]
      @clip_middle_name   = @config[:clip_middle_name]
      @clip_last_name     = @config[:clip_last_name]
      @clip_date_of_birth = @config[:clip_date_of_birth]
      @clip_relationship  = @config[:clip_relationship]

      @center = @member.center
      @branch = @member.branch

      @loan = Loan.new

      @member_data = @member.data.with_indifferent_access

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
      cmd = ::Loans::Fetch.new(
              config: {
                loan: nil,
                member: @member
              }
            )

      cmd.execute!

      @loan_data  = cmd.data

      @loan.pn_number         = @pn_number
      @loan.date_prepared     = Date.today
      @loan.principal         = @amount
      @loan.num_installments  = @num_installments
      @loan.project_type_id   = @project_type.try(:id)
      @loan.term              = @term
      @loan.payment_type      = @loan_data[:payment_type]
      @loan.data              = @loan_data[:data]

      # Flag loan as remote application
      @loan.data[:is_remote_application] = true

      # Loan co-makers
      @loan.data[:co_maker_two] = @co_maker_two
      @loan.data[:co_maker_one] = {
        id: @co_maker_one.try(:id),
        first_name: @co_maker_one.try(:first_name),
        middle_name: @co_maker_one.try(:middle_name),
        last_name: @co_maker_one.try(:last_name)
      }

      # CLIP information
      @loan.data["clip_beneficiary"]["first_name"]    = @clip_first_name
      @loan.data["clip_beneficiary"]["middle_name"]   = @clip_middle_name
      @loan.data["clip_beneficiary"]["last_name"]     = @clip_last_name
      @loan.data["clip_beneficiary"]["date_of_birth"] = @clip_date_of_birth
      @loan.data["clip_beneficiary"]["relationship"]  = @clip_relationship

      # Setup loan cycle
      @loan_cycles = @member_data["loan_cycles"]

      if @loan_cycles.blank? || @loan_cycles.size == 0
        @loan.cycle = 1
      else
        @loan_cycles.each_with_index do |c, i|
          if c["loan_product_id"] == @loan_product.id
            @loan.cycle = c["cycle"] + 1
          end
        end
      end
      
      # Repair loan cycles
      if @loan.cycle.blank? 
        latest_loan = ReadOnlyLoan.paid.where(loan_product_id: @loan_product.id, member_id: @member.id).order("updated_at DESC").first

        if latest_loan.present?
          @loan.cycle = latest_loan.cycle + 1
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
        num_installments: @num_installments,
        term: @term
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

      # Initial status of loan for remote application should be for-verification
      @loan.status = "for-verification"

      if @persist
        @loan.save!
      end

      @loan
    end
  end
end
