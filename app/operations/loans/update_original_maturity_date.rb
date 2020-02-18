module Loans
  class UpdateOriginalMaturityDate
    attr_accessor :original_maturity_date

    def initialize(loan:, save: true)
      @loan = loan
      @term = @loan.term
      @save = save

      @num_installments = @loan.num_installments

      @original_maturity_date = nil
    end

    def execute!
      case @term
      when "weekly"
        @original_maturity_date = @loan.date_released || @loan.date_approved

        @num_installments.times do
          @original_maturity_date = @original_maturity_date + 7.days
        end
      when "quarterly"
        @original_maturity_date = @loan.date_released || @loan.date_approved

        @num_installments.times do
          @original_maturity_date = @original_maturity_date + 3.months
        end
      when "monthly"
        @original_maturity_date = @loan.date_released || @loan.date_approved + @num_installments.months
      when "semi-monthly"
        @original_maturity_date = @loan.date_released || @loan.date_approved

        @num_installments.times do
          @original_maturity_date = @original_maturity_date + 15.days
        end
      when "daily"
        @original_maturity_date = @loan.date_released || @loan.date_approved + @num_installments.days
      else
        raise "Unsupported term #{@term}"
      end

      if @save
        @loan.update!(
          original_maturity_date: original_maturity_date
        )
      end
    end
  end
end
