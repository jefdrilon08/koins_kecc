module Loans
  class DelayAmort
    def initialize(config:)
      @config   = config
      @amort    = @config[:amort]
      @user     = @config[:user]
      @reason   = @config[:reason]
      @new_date = @config[:new_date].try(:to_date)

      @loan         = @amort.loan
      @member       = @loan.member
      @loan_product = @loan.loan_product
      @branch       = @loan.branch
      @center       = @loan.center

      @data = @loan.data.with_indifferent_access

      @current_date = Date.today

      @moratorium_records = @data[:moratorium_records] || []

      @amorts_to_update = @loan.amortization_schedule_entries.unpaid.where(
                            "due_date > ?",
                            @amort.due_date
                          ).order("due_date ASC")
    end

    def execute!
      @moratorium_records << {
        loan: {
          id: @loan.id,
          pn_number: @loan.pn_number
        },
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        center: {
          id: @center.id,
          name: @center.name
        },
        loan_product: {
          id: @loan_product.id,
          name: @loan_product.name
        },
        member: {
          id: @member.id,
          first_name: @member.first_name,
          middle_name: @member.middle_name,
          last_name: @member.last_name
        },
        amortization_schedule_entry: @amort,
        user: {
          id: @user.id,
          first_name: @user.first_name,
          last_name: @user.last_name,
          identification_number: @user.identification_number
        },
        date_changed: @current_date,
        new_date: @new_date
      }

      @data[:moratorium_records]  = @moratorium_records

      # Update amorts
      @amort.update!(
        due_date: @new_date
      )

      @amorts_to_update.each do |a|
        if @loan.term == "weekly"
          @new_date = @new_date + 7.days
          a.update!(due_date: @new_date)
        elsif @loan.term == "monthly"
          @new_date = @new_date + 1.month
          a.update!(due_date: @new_date)
        elsif @loan.term == "semi-monthly"
          @new_date = @new_date + 15.days
          a.update!(due_date: @new_date)
        elsif @loan.term == "semi-annually"
          @new_date = @new_date + 183.days
          a.update!(due_date: @new_date)
        elsif @loan.term == "quarterly"
          @new_date = @new_date + 90.days
          a.update!(due_date: @new_date)
        elsif @loan.term == "daily"
          @new_date = @new_date + 1.day
          a.update!(due_date: @new_date)
        else
          raise "invalid term #{@loan.term}"
        end
      end

      @loan.update!(
        data: @data
      )
    end
  end
end
