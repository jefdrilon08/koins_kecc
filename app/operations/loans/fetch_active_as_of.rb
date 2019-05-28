module Loans
  class FetchActiveAsOf
    def initialize(config:)
      @config = config

      @as_of        = @config[:as_of].try(:to_date) || Date.today
      @branch       = @config[:branch]
      @center       = @config[:center]
      @loan_product = @config[:loan_product]
      @member       = @config[:member]

      if @member.present?
        @branch = @member.branch
        @center = @member.center
      end

      @data = {
        loans: []
      }
    end

    def execute!
      @paid_loans = Loan.paid.where(
                      "date_approved <= ? AND date_completed > ?",
                      @as_of,
                      @as_of
                    )

      @active_loans = Loan.active.where(
                        "date_approved <= ?",
                        @as_of
                      )

      if @member.present?
        @paid_loans   = @paid_loans.where(member_id: @member.id)
        @active_loans = @active_loans.where(member_id: @member.id)
      end

      if @branch.present?
        @paid_loans   = @paid_loans.where(branch_id: @branch.id)
        @active_loans = @active_loans.where(branch_id: @branch.id)
      end

      if @center.present?
        @paid_loans   = @paid_loans.where(center_id: @center.id)
        @active_loans = @active_loans.where(center_id: @center.id)
      end

      if @loan_product.present?
        @paid_loans   = @paid_loans.where(loan_product_id: @loan_product.id)
        @active_loans = @active_loans.where(loan_product_id: @loan_product.id)
      end

      @loans  = Loan.where(id: [@paid_loans.pluck(:id) + @active_loans.pluck(:id)])

      @loans
    end
  end
end
