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

        @center_ids = Center.where(branch_id: @branch.id).pluck(:id)

        if @meta[:center][:id].present?
          @center_ids = [@meta[:center][:id]]
        end

        @loan_ids = Loan.active.where(
                      branch_id: @branch.id,
                      center_id: @center_ids
                    ).pluck(:id)
      end

      def execute!
        @loan_ids.each do |loan_id|
          amortization_schedule_entries = AmortizationScheduleEntry.unpaid.where(
                                            "loan_id = ? AND due_date >= ?",
                                            loan_id,
                                            @date_initialized
                                          ).order("due_date ASC")

          if amortization_schedule_entries.any?
            current_date  = amortization_schedule_entries.first.due_date
            iter = 1
            amortization_schedule_entries.each do |o|
              if iter == 1
                o.update!(due_date: current_date + @number_of_days.days)
              else
                o.update!(due_date: current_date + 7.days)
              end

              current_date = o.due_date
              iter = iter + 1
            end
          end
        end

        @adjustment_record.update!(status: "approved")
      end
    end
  end
end
