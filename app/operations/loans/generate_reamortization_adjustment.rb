module Loans
  class GenerateReamortizationAdjustment
    def initialize(config:)
      @config       = config
      @loan         = @config[:loan]
      @loan_product = @loan.loan_product

      @current_date = @config[:current_date] || Date.today

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

      @original_monthly_interest_rate = @loan.monthly_interest_rate
      @original_principal             = @loan.principal
      @original_interest              = @loan.interest
      @original_principal_paid        = @loan.principal_paid

      @data = {
        meta: {
          subsidiary_id: @loan.id,
          date_generated: @current_date
        },
        data: {
          original_amortization: [],
          new_amortization: []
        }
      }

      @amortization_to_adjust = @loan.amortization_schedule_entries.where(
                                  "principal_paid = 0 AND interest_paid = 0"
                                ).order("due_date ASC")
    end

    def execute!
      build_original_amortization!
      
      @data
    end

    private

    def build_original_amortization!
      @loan.amortization_schedule_entries.order("due_date ASC").each do |o|
        @data[:data][:original_amortization] << {
          id: o.id,
          amount_due: o.amount_due,
          principal: o.principal,
          interest: o.interest,
          principal_paid: o.principal_paid,
          interest_paid: o.interest_paid,
          principal_balance: o.principal_balance,
          interest_balance: o.interest_balance,
          due_date: o.due_date,
          is_paid: o.is_paid,
          data: o.data
        }
      end
    end
  end
end
