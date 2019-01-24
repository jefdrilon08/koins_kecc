module Loans
  class BuildSoaExpenseObject
    def initialize(loan:)
      @loan   = loan
      @member = @loan.member
      @branch = @loan.branch
      @center = @loan.center

      @loan_product = @loan.loan_product

      @data = {
        loan: {
          id: @loan.id,
          date_released: @loan.date_released
        },
        member: {
          id: @member.id,
          first_name: @member.first_name,
          middle_name: @member.middle_name,
          last_name: @member.last_name,
          full_name: @member.full_name
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
        principal: @loan.principal.round(2),
        date_released: @loan.date_released.strftime("%B %d, %Y"),
        bank_check_number: @loan.data.with_indifferent_access[:voucher][:bank_check_number],
        check_number: @loan.data.with_indifferent_access[:voucher][:check_number],
        name_of_person_in_check: @loan.data.with_indifferent_access[:voucher][:payee]
      }
    end

    def execute!
      @data
    end
  end
end
