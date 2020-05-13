module Adjustments
  module BatchMoratoriumAdjustments
    class Approve
      def initialize(config:)
        @config             = config
        @adjustment_record  = @config[:adjustment_record]
        @user               = @config[:user]

        @data = @adjustment_record.data.with_indifferent_access
        @meta = @adjustment_record.meta.with_indifferent_access

        @date_initialized = @data[:date_initialized].to_date
        @number_of_days   = @data[:number_of_days].to_i
        @branch           = Branch.find(@meta[:branch][:id])

        if @meta[:center][:id].present?
          @center = Center.find(@meta[:center][:id])
        end

        @loans  = Loan.active.where(
                    branch_id: @branch.id
                  )

        if @center.present?
          @loans  = @loans.where(center_id: @center.id)
        end

        @amortization_schedule_entries  = AmortizationScheduleEntry.unpaid.where(
                                            "loan_id IN (?) AND due_date >= ?",
                                            @loans.pluck(:id),
                                            @date_initialized
                                          )
      end

      def execute!
        current_date  = @amortization_schedule_entries.first

        @amortization_schedule_entries.each do |o|
          o.update!(due_date: current_date + @number_of_days.days)

          current_date = o.due_date
        end

        @adjustment_record.update!(status: "approved")
      end
    end
  end
end
