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
    end

    def execute!
      @loan.pn_number         = @loan_data[:pn_number]
      @loan.date_prepared     = @loan_data[:date_prepared]
      @loan.date_released     = @loan_data[:date_released]
      @loan.principal         = @loan_data[:principal].to_f.round(2)
      @loan.num_installments  = @loan_data[:num_installments]
      @loan.term              = @loan_data[:term]
      @loan.data              = @loan_data[:data]

      @loan.member                = @member
      @loan.branch                = @branch
      @loan.center                = @center
      @loan.loan_product          = @loan_product
      @loan.monthly_interest_rate = @loan_product.monthly_interest_rate

      params  = {
        principal: @loan.principal,
        annual_interest_rate: (@loan_product.monthly_interest_rate * 12),
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

      accounting_entry_data = ::Loans::BuildAccountingEntry.new(
                                config: {
                                  member: @member,
                                  loan_product: @loan_product,
                                  amount: @loan.principal,
                                  term: @loan.term,
                                  num_installments: @loan.num_installments,
                                  particular: particular,
                                  loan: @loan
                                }
                              ).execute!

      @loan.data[:accounting_entry] = accounting_entry_data

      @loan.save!

      @loan
    end
  end
end
